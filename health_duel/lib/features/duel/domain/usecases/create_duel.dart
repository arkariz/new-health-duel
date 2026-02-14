import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Create Duel Use Case
///
/// Business logic for creating a new 24-hour step count duel.
///
/// **Validation:**
/// - Cannot challenge yourself
/// - Cannot have active duel with same user
class CreateDuel {
  final DuelRepository _repository;

  const CreateDuel(this._repository);

  /// Execute duel creation
  ///
  /// Returns created [Duel] in pending status or [Failure].
  Future<Either<Failure, Duel>> call({
    required String challengerId,
    required String challengedId,
  }) async {
    // Validation: Cannot challenge yourself
    if (challengerId == challengedId) {
      return const Left(ValidationFailure(message: 'Cannot challenge yourself'));
    }

    // Business rule: Check if users already have active duel
    final existingDuel = await _repository.getActiveDuelBetween(
      challengerId,
      challengedId,
    );

    return existingDuel.fold(
      (failure) {
        // No existing duel (or error checking), proceed with creation
        return _repository.createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
        );
      },
      (duel) {
        // Check if active duel exists
        if (duel != null) {
          return const Left(ValidationFailure(
            message: 'You already have an active duel with this user',
          ));
        }
        // No active duel, create new one
        return _repository.createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
        );
      },
    );
  }
}
