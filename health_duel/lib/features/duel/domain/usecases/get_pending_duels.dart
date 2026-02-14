import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Get Pending Duels Use Case
///
/// Retrieve all pending duel invitations for a user.
class GetPendingDuels {
  final DuelRepository _repository;

  const GetPendingDuels(this._repository);

  /// Execute query
  ///
  /// Returns list of pending duels where user is challenged.
  Future<Either<Failure, List<Duel>>> call(String userId) {
    return _repository.getPendingDuels(userId);
  }
}
