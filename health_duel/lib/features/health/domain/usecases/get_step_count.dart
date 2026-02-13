import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Fetches step count for a time range.
///
/// Business logic (ADR-006):
/// - Validates time range
/// - Creates [StepCount] entity with invariant checks
/// - Future: duel period validation
class GetStepCount {
  final HealthRepository _repository;

  const GetStepCount(this._repository);

  Future<Either<Failure, StepCount>> call({required DateTime startTime, required DateTime endTime}) async {
    // Validate time range
    if (startTime.isAfter(endTime)) {
      return const Left(ValidationFailure(message: 'Start time must be before end time', errorCode: 'invalid_time_range'));
    }

    final result = await _repository.getStepCount(startTime: startTime, endTime: endTime);

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

        // TODO(Phase 5): Validate steps within duel period
        // if (duelPeriod != null && !stepCount.isWithinPeriod(duelStart, duelEnd)) {
        //   return Left(StepsOutsideDuelPeriodFailure());
        // }

        return Right(stepCount);
      } on ArgumentError catch (e) {
        return Left(ValidationFailure(message: e.message.toString(), errorCode: 'invalid_step_data'));
      }
    });
  }
}
