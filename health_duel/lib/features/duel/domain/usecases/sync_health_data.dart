import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';

/// Sync Health Data Use Case
///
/// Fetch step count from Health platform and update duel.
///
/// **Flow:**
/// 1. Get duel to extract time window
/// 2. Fetch steps from HealthKit/Health Connect
/// 3. Update duel with fetched step count
class SyncHealthData {
  final HealthRepository _healthRepository;
  final DuelRepository _duelRepository;

  const SyncHealthData(this._healthRepository, this._duelRepository);

  /// Execute health data sync
  ///
  /// Returns updated [Duel] or [Failure].
  Future<Either<Failure, Duel>> call({
    required String duelId,
    required String userId,
  }) async {
    // Get duel to extract time window
    final duelResult = await _duelRepository.getDuelById(duelId);

    return duelResult.fold(
      (failure) => Left(failure),
      (duel) async {
        // Validation: Only sync active duels
        if (!duel.isActive) {
          return const Left(ValidationFailure(message: 'Duel is not active'));
        }

        // Fetch steps from health platform for duel time window
        final stepsResult = await _healthRepository.getStepCount(
          startTime: duel.startTime,
          endTime: DateTime.now(), // Current time (capped at endTime by platform)
        );

        return stepsResult.fold(
          (failure) => Left(failure),
          (stepCount) async {
            // Update duel with fetched step count
            return _duelRepository.updateStepCount(
              duelId: duelId,
              userId: userId,
              steps: StepCount(stepCount.value),
            );
          },
        );
      },
    );
  }
}
