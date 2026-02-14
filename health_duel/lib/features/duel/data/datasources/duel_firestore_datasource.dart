import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/features/duel/data/models/duel_dto.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';

/// Duel Firestore Data Source
///
/// Handles all Firestore operations for duels.
class DuelFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const DuelFirestoreDataSource(this._firestore);

  /// Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _duelsCollection =>
      _firestore.collection('duels');

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
  Future<DuelDto> acceptDuel(String duelId) async {
    final now = DateTime.now();
    final endTime = now.add(const Duration(hours: 24));

    await _duelsCollection.doc(duelId).update({
      'status': DuelStatus.active.name,
      'startTime': Timestamp.fromDate(now),
      'endTime': Timestamp.fromDate(endTime),
      'acceptedAt': Timestamp.fromDate(now),
    });

    // Return updated duel
    final doc = await _duelsCollection.doc(duelId).get();
    return DuelDto.fromFirestore(doc);
  }

  /// Cancel/decline a duel
  ///
  /// Sets status to cancelled.
  Future<void> cancelDuel(String duelId) async {
    await _duelsCollection.doc(duelId).update({
      'status': DuelStatus.cancelled.name,
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

    return query.docs.map((doc) => DuelDto.fromFirestore(doc)).toList();
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

    return query.docs.map((doc) => DuelDto.fromFirestore(doc)).toList();
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

    return query.docs.map((doc) => DuelDto.fromFirestore(doc)).toList();
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
        .map((doc) => DuelDto.fromFirestore(doc))
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
            query.docs.map((doc) => DuelDto.fromFirestore(doc)).toList());
  }
}
