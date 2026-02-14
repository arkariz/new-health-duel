import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Accept Duel Use Case
///
/// Business logic for accepting a pending duel invitation.
///
/// **Validation:**
/// - Only pending duels can be accepted
/// - Pending invitation must not be expired
class AcceptDuel {
  final DuelRepository _repository;

  const AcceptDuel(this._repository);

  /// Execute duel acceptance
  ///
  /// Transitions duel from pending to active.
  /// Sets start/end timestamps (24-hour window).
  ///
  /// Returns updated [Duel] or [Failure].
  Future<Either<Failure, Duel>> call(String duelId) async {
    // Get current duel state
    final duelResult = await _repository.getDuelById(duelId);

    return duelResult.fold(
      (failure) => Left(failure),
      (duel) async {
        // Validation: Can only accept pending duels
        if (!duel.status.canBeAccepted) {
          return Left(ValidationFailure(
            message: 'Duel cannot be accepted (status: ${duel.status})',
          ));
        }

        // Validation: Check if pending invitation expired
        if (duel.isPendingExpired) {
          return const Left(ValidationFailure(
            message: 'Duel invitation has expired',
          ));
        }

        // Accept duel (repository handles status transition and timestamps)
        return _repository.acceptDuel(duelId);
      },
    );
  }
}
