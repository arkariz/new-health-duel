import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Get Active Duels Use Case
///
/// Retrieve all active duels for a user.
class GetActiveDuels {
  final DuelRepository _repository;

  const GetActiveDuels(this._repository);

  /// Execute query
  ///
  /// Returns list of active duels where user is a participant.
  Future<Either<Failure, List<Duel>>> call(String userId) {
    return _repository.getActiveDuels(userId);
  }
}
