import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/features/challenge/data/models/solo_challenge_dto.dart';
import 'package:health_duel/features/challenge/domain/value_objects/challenge_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_metric.dart';

/// Solo Challenge Firestore Data Source
///
/// All operations are scoped under `users/{uid}/challenges/{id}` —
/// owner-only, single writer. No transactions needed: unlike a duel,
/// nothing here is contended between two devices.
class SoloChallengeFirestoreDataSource {
  const SoloChallengeFirestoreDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _challengesOf(String userId) =>
      _firestore.collection('users').doc(userId).collection('challenges');

  Future<SoloChallengeDto> startChallenge({
    required String userId,
    required int target,
    required DuelMetric metric,
  }) async {
    final now = DateTime.now();
    final docRef = _challengesOf(userId).doc();

    final data = {
      'userId': userId,
      'metric': metric.name,
      'target': target,
      'currentValue': 0,
      'status': ChallengeStatus.active.name,
      'startTime': Timestamp.fromDate(now),
      'endTime': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'createdAt': Timestamp.fromDate(now),
      'completedAt': null,
    };

    await docRef.set(data);
    final doc = await docRef.get();
    return SoloChallengeDto.fromFirestore(doc);
  }

  Future<SoloChallengeDto?> getActiveChallenge(String userId) async {
    final query = await _challengesOf(userId)
        .where('status', isEqualTo: ChallengeStatus.active.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return SoloChallengeDto.fromFirestore(query.docs.first);
  }

  /// Finalize an expired active challenge. Idempotent: a challenge that's
  /// no longer `active` is returned unchanged without writing.
  Future<SoloChallengeDto> completeChallenge({
    required String userId,
    required String challengeId,
  }) async {
    final docRef = _challengesOf(userId).doc(challengeId);
    final doc = await docRef.get();
    final dto = SoloChallengeDto.fromFirestore(doc);

    if (dto.status != ChallengeStatus.active.name) return dto;

    await docRef.update({
      'status': ChallengeStatus.completed.name,
      'completedAt': Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(dto.endTimestamp),
      ),
    });

    final updated = await docRef.get();
    return SoloChallengeDto.fromFirestore(updated);
  }

  Future<List<SoloChallengeDto>> getChallengeHistory(String userId) async {
    final query = await _challengesOf(userId)
        .where('status', isEqualTo: ChallengeStatus.completed.name)
        .orderBy('completedAt', descending: true)
        .get();

    return query.docs.map(SoloChallengeDto.fromFirestore).toList();
  }

  Future<SoloChallengeDto> updateProgress({
    required String userId,
    required String challengeId,
    required int value,
  }) async {
    final docRef = _challengesOf(userId).doc(challengeId);
    await docRef.update({'currentValue': value});
    final doc = await docRef.get();
    return SoloChallengeDto.fromFirestore(doc);
  }

  Stream<SoloChallengeDto> watchChallenge({
    required String userId,
    required String challengeId,
  }) {
    return _challengesOf(userId).doc(challengeId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Challenge not found: $challengeId');
      }
      return SoloChallengeDto.fromFirestore(doc);
    });
  }
}
