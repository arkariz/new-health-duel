import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Decline Duel Use Case
///
/// Business logic for declining a pending duel invitation.
///
/// **Validation:**
/// - Only pending duels can be declined
class DeclineDuel {
  final DuelRepository _repository;

  const DeclineDuel(this._repository);

  /// Execute duel decline
  ///
  /// Sets duel status to cancelled.
  ///
  /// Returns [void] on success or [Failure].
  Future<Either<Failure, void>> call(String duelId) async {
    // Get current duel state
    final duelResult = await _repository.getDuelById(duelId);

    return duelResult.fold(
      (failure) => Left(failure),
      (duel) async {
        // Validation: Can only cancel/decline pending duels
        if (!duel.status.canBeCancelled) {
          return Left(ValidationFailure(
            message: 'Duel cannot be declined (status: ${duel.status})',
          ));
        }

        return _repository.cancelDuel(duelId);
      },
    );
  }
}
