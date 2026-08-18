import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/repositories/solo_challenge_repository.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';

/// Sync Health Data Use Case (Solo Challenge)
///
/// Mirrors duel/domain/usecases/sync_health_data.dart, but for a single
/// participant: fetch steps for the challenge window, write it as the
/// challenge's whole progress value (no field-scoping needed — one writer).
class SyncSoloChallengeHealthData {
  const SyncSoloChallengeHealthData(this._healthRepository, this._challengeRepository);
  final HealthRepository _healthRepository;
  final SoloChallengeRepository _challengeRepository;

  Future<Either<Failure, SoloChallenge>> call({
    required String userId,
    required String challengeId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final now = DateTime.now();
    final effectiveEndTime = now.isAfter(endTime) ? endTime : now;

    final stepsResult = await _healthRepository.getStepCount(
      startTime: startTime,
      endTime: effectiveEndTime,
    );

    return stepsResult.fold(
      Left.new,
      (stepCount) => _challengeRepository.updateProgress(
        userId: userId,
        challengeId: challengeId,
        value: stepCount.value,
      ),
    );
  }
}
