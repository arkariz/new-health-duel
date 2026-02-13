import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Fetches today's step count (midnight to now).
///
/// Business logic (ADR-006):
/// - Creates [StepCount] entity with invariant checks
/// - Validates data is from today
/// - Future: freshness check
class GetTodaySteps {
  final HealthRepository _repository;

  const GetTodaySteps(this._repository);

  Future<Either<Failure, StepCount>> call() async {
    final result = await _repository.getTodaySteps();

    // Create entity with business validation
    return result.fold(Left.new, (raw) {
      try {
        final stepCount = StepCount.create(
          value: raw.value,
          startTime: raw.startTime,
          endTime: raw.endTime,
          sourceDevice: raw.sourceDevice,
          hasManualEntries: raw.hasManualEntries,
        );

        // TODO(Phase 5): Warn if data is stale (> 1 hour)

        // Verify it's actually today's data
        if (!stepCount.isToday) {
          return const Left(ValidationFailure(message: 'Received step data is not from today', errorCode: 'stale_step_data'));
        }

        return Right(stepCount);
      } on ArgumentError catch (e) {
        return Left(ValidationFailure(message: e.message.toString(), errorCode: 'invalid_step_data'));
      }
    });
  }
}
