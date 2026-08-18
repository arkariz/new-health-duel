import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_metric.dart';

/// Solo Challenge Repository Interface
abstract class SoloChallengeRepository {
  /// Start a new 24h challenge for [userId].
  Future<Either<Failure, SoloChallenge>> startChallenge({
    required String userId,
    required int target,
    DuelMetric metric = DuelMetric.steps,
  });

  /// The user's current active (or expired-but-unfinalized) challenge,
  /// if any.
  Future<Either<Failure, SoloChallenge?>> getActiveChallenge(String userId);

  /// Finalize an expired active challenge (client-side completion),
  /// writing `status=completed`. Idempotent.
  Future<Either<Failure, SoloChallenge>> completeChallenge({
    required String userId,
    required String challengeId,
  });

  /// Completed challenges for [userId], most recent first.
  Future<Either<Failure, List<SoloChallenge>>> getChallengeHistory(
    String userId,
  );

  /// Overwrite the challenge's progress value (owner-only, single writer —
  /// no field-level tampering concern like a duel has).
  Future<Either<Failure, SoloChallenge>> updateProgress({
    required String userId,
    required String challengeId,
    required int value,
  });

  /// Real-time updates for a single challenge.
  Stream<Either<Failure, SoloChallenge>> watchChallenge({
    required String userId,
    required String challengeId,
  });
}
