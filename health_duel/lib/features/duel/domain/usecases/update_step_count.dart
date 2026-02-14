import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';

/// Update Step Count Use Case
///
/// Business logic for updating participant step count in a duel.
///
/// **Validation:**
/// - Only active duels can be updated
/// - User must be a participant
class UpdateStepCount {
  final DuelRepository _repository;

  const UpdateStepCount(this._repository);

  /// Execute step count update
  ///
  /// Updates step count for specified user in the duel.
  ///
  /// Returns updated [Duel] or [Failure].
  Future<Either<Failure, Duel>> call({
    required String duelId,
    required String userId,
    required StepCount steps,
  }) async {
    // Get current duel state
    final duelResult = await _repository.getDuelById(duelId);

    return duelResult.fold(
      (failure) => Left(failure),
      (duel) async {
        // Validation: Only update active duels
        if (!duel.isActive) {
          return const Left(ValidationFailure(
            message: 'Cannot update non-active duel',
          ));
        }

        // Validation: User must be participant
        if (!duel.isParticipant(userId)) {
          return const Left(ValidationFailure(
            message: 'User is not a participant in this duel',
          ));
        }

        return _repository.updateStepCount(
          duelId: duelId,
          userId: userId,
          steps: steps,
        );
      },
    );
  }
}
