import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/duel/data/models/duel_dto.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';

/// Duel Firestore Data Source
///
/// Handles all Firestore operations for duels.
class DuelFirestoreDataSource {

  const DuelFirestoreDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _duelsCollection =>
      _firestore.collection('duels');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create a new duel
  ///
  /// Creates pending duel document in Firestore.
  /// User data (names, photos) must be provided for denormalization.
  Future<DuelDto> createDuel({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    String? challengerPhotoUrl,
    String? challengedPhotoUrl,
  }) async {
    final now = DateTime.now();
    final docRef = _duelsCollection.doc();

    final duelData = {
      'challengerId': challengerId,
      'challengedId': challengedId,
      'challengerSteps': 0,
      'challengedSteps': 0,
      'status': DuelStatus.pending.name,
      'startTime': Timestamp.fromDate(now), // Placeholder (updated on accept)
      'endTime': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'createdAt': Timestamp.fromDate(now),
      'acceptedAt': null,
      'completedAt': null,
      'participants': [challengerId, challengedId],
      'winnerId': null,
      'challengerName': challengerName,
      'challengedName': challengedName,
      'challengerPhotoUrl': challengerPhotoUrl,
      'challengedPhotoUrl': challengedPhotoUrl,
    };

    await docRef.set(duelData);

    // Return created duel
    final doc = await docRef.get();
    return DuelDto.fromFirestore(doc);
  }

  /// Accept a pending duel
  ///
  /// Transitions duel to active status and sets start/end timestamps.
  ///
  /// Guarded by a transaction: rejects the accept if the duel is no longer
  /// pending or its 24-hour invitation window has already elapsed. Without
  /// this, a stale client (e.g. a background sweep racing a user tap) could
  /// accept a duel that another writer had already cancelled or expired.
  Future<DuelDto> acceptDuel(String duelId) async {
    final docRef = _duelsCollection.doc(duelId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw Exception('Duel not found: $duelId');
      }

      final data = doc.data()!;
      if (data['status'] != DuelStatus.pending.name) {
        throw ValidationFailure(
          message: 'Duel cannot be accepted (status: ${data['status']})',
        );
      }

      // While status is pending, endTime holds the pending-invitation
      // deadline (createdAt + 24h) — see expirePendingDuel below.
      final expiresAt = (data['endTime'] as Timestamp).toDate();
      final now = DateTime.now();
      if (now.isAfter(expiresAt)) {
        throw const ValidationFailure(
          message: 'Duel invitation has expired',
        );
      }

      final endTime = now.add(const Duration(hours: 24));
      transaction.update(docRef, {
        'status': DuelStatus.active.name,
        'startTime': Timestamp.fromDate(now),
        'endTime': Timestamp.fromDate(endTime),
        'acceptedAt': Timestamp.fromDate(now),
      });
    });

    // Return updated duel
    return getDuelById(duelId);
  }

  /// Finalize an expired active duel (client-side completion)
  ///
  /// Atomically writes status=completed, winnerId (null on tie), and
  /// completedAt=endTime via a Firestore transaction. Idempotent: if the
  /// duel is no longer active (already completed by the other participant
  /// or a sweep), returns the duel unchanged without writing.
  Future<DuelDto> completeDuel(String duelId) async {
    final docRef = _duelsCollection.doc(duelId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw Exception('Duel not found: $duelId');
      }

      final data = doc.data()!;
      if (data['status'] != DuelStatus.active.name) {
        // Already completed/cancelled by another writer — idempotent success
        return;
      }

      final endTime = (data['endTime'] as Timestamp).toDate();
      if (DateTime.now().isBefore(endTime)) {
        throw const ValidationFailure(message: 'Duel has not ended yet');
      }

      final challengerSteps = data['challengerSteps'] as int? ?? 0;
      final challengedSteps = data['challengedSteps'] as int? ?? 0;
      final String? winnerId;
      if (challengerSteps == challengedSteps) {
        winnerId = null; // Tie
      } else {
        winnerId = challengerSteps > challengedSteps
            ? data['challengerId'] as String
            : data['challengedId'] as String;
      }

      transaction.update(docRef, {
        'status': DuelStatus.completed.name,
        'winnerId': winnerId,
        // Deterministic completedAt: winner is decided exactly at the
        // 24-hour mark, and racing writers produce identical payloads.
        'completedAt': Timestamp.fromDate(endTime),
      });
    });

    // Return updated duel
    return getDuelById(duelId);
  }

  /// Finalize a pending invitation that was never accepted in time
  /// (client-side expiration)
  ///
  /// Atomically writes status=expired via a Firestore transaction.
  /// Idempotent: if the duel is no longer pending (already accepted,
  /// declined, or expired by another writer), returns the duel unchanged
  /// without writing.
  Future<DuelDto> expirePendingDuel(String duelId) async {
    final docRef = _duelsCollection.doc(duelId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw Exception('Duel not found: $duelId');
      }

      final data = doc.data()!;
      if (data['status'] != DuelStatus.pending.name) {
        // Already accepted/declined/expired by another writer — idempotent success
        return;
      }

      // While status is pending, endTime holds createdAt + 24h (set by
      // createDuel and only overwritten once the duel is accepted) — the
      // pending-invitation deadline, read straight from the document
      // instead of recomputed here.
      final expiresAt = (data['endTime'] as Timestamp).toDate();
      if (DateTime.now().isBefore(expiresAt)) {
        throw const ValidationFailure(
          message: 'Pending duel has not expired yet',
        );
      }

      transaction.update(docRef, {
        'status': DuelStatus.expired.name,
      });
    });

    // Return updated duel
    return getDuelById(duelId);
  }

  /// Cancel/decline a duel
  ///
  /// Sets status to cancelled.
  ///
  /// Guarded by a transaction so only a duel still in `pending` status can
  /// be cancelled. Without this, calling the method directly (bypassing the
  /// use-case's client-side check) could cancel a live, in-progress
  /// (`active`) duel.
  Future<void> cancelDuel(String duelId) async {
    final docRef = _duelsCollection.doc(duelId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw Exception('Duel not found: $duelId');
      }

      final data = doc.data()!;
      if (data['status'] != DuelStatus.pending.name) {
        throw ValidationFailure(
          message: 'Duel cannot be cancelled (status: ${data['status']})',
        );
      }

      transaction.update(docRef, {
        'status': DuelStatus.cancelled.name,
      });
    });
  }

  /// Get duel by ID
  Future<DuelDto> getDuelById(String duelId) async {
    final doc = await _duelsCollection.doc(duelId).get();

    if (!doc.exists) {
      throw Exception('Duel not found: $duelId');
    }

    return DuelDto.fromFirestore(doc);
  }

  /// Get active duels for a user
  ///
  /// Queries duels where:
  /// - User is in participants array
  /// - Status is active
  /// - Sorted by start time (newest first)
  Future<List<DuelDto>> getActiveDuels(String userId) async {
    final query = await _duelsCollection
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: DuelStatus.active.name)
        .orderBy('startTime', descending: true)
        .get();

    return query.docs.map(DuelDto.fromFirestore).toList();
  }

  /// Get pending duel invitations for a user
  ///
  /// Queries duels where:
  /// - User is challenged (not challenger)
  /// - Status is pending
  /// - Sorted by creation time (newest first)
  Future<List<DuelDto>> getPendingDuels(String userId) async {
    final query = await _duelsCollection
        .where('challengedId', isEqualTo: userId)
        .where('status', isEqualTo: DuelStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map(DuelDto.fromFirestore).toList();
  }

  /// Get outgoing (sent) pending duel challenges for a user
  ///
  /// Queries duels where:
  /// - User is the challenger
  /// - Status is pending
  /// - Sorted by creation time (newest first)
  Future<List<DuelDto>> getSentDuels(String userId) async {
    final query = await _duelsCollection
        .where('challengerId', isEqualTo: userId)
        .where('status', isEqualTo: DuelStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map(DuelDto.fromFirestore).toList();
  }

  /// Get duel history (completed duels) for a user
  ///
  /// Queries completed duels sorted by completion time.
  Future<List<DuelDto>> getDuelHistory(String userId) async {
    final query = await _duelsCollection
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: DuelStatus.completed.name)
        .orderBy('completedAt', descending: true)
        .get();

    return query.docs.map(DuelDto.fromFirestore).toList();
  }

  /// Check if active duel exists between two users
  ///
  /// Returns duel if found, null otherwise.
  Future<DuelDto?> getActiveDuelBetween(
    String userId1,
    String userId2,
  ) async {
    // Query active duels for user1
    final query = await _duelsCollection
        .where('participants', arrayContains: userId1)
        .where('status', isEqualTo: DuelStatus.active.name)
        .get();

    // Filter results to find duel with user2
    final duels = query.docs
        .map(DuelDto.fromFirestore)
        .where((duel) =>
            duel.participants.contains(userId2) &&
            duel.participants.contains(userId1))
        .toList();

    return duels.isEmpty ? null : duels.first;
  }

  /// Update step count for a participant
  Future<DuelDto> updateStepCount({
    required String duelId,
    required String userId,
    required int steps,
  }) async {
    // Determine which field to update (challenger or challenged)
    final doc = await _duelsCollection.doc(duelId).get();
    final duel = DuelDto.fromFirestore(doc);

    final fieldName = duel.challengerId == userId
        ? 'challengerSteps'
        : 'challengedSteps';

    await _duelsCollection.doc(duelId).update({
      fieldName: steps,
    });

    // Return updated duel
    final updatedDoc = await _duelsCollection.doc(duelId).get();
    return DuelDto.fromFirestore(updatedDoc);
  }

  /// Watch real-time duel updates
  ///
  /// Returns stream that emits whenever duel document changes.
  Stream<DuelDto> watchDuel(String duelId) {
    return _duelsCollection.doc(duelId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Duel not found: $duelId');
      }
      return DuelDto.fromFirestore(doc);
    });
  }

  /// Get all users except the current user (potential opponents)
  ///
  /// Used for opponent selection in duel creation.
  /// Ordered alphabetically by name.
  Future<List<UserModel>> getOpponents(String excludeUserId) async {
    final query = await _usersCollection.orderBy('name').get();

    return query.docs
        .map(UserModel.fromFirestore)
        .where((user) => user.id != excludeUserId)
        .toList();
  }

  /// Watch real-time active duels for user
  ///
  /// Returns stream that emits whenever user's active duels change.
  Stream<List<DuelDto>> watchActiveDuels(String userId) {
    return _duelsCollection
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: DuelStatus.active.name)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((query) =>
            query.docs.map(DuelDto.fromFirestore).toList());
  }
}
