import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Get Duel History Use Case
///
/// Retrieve completed duels for a user.
class GetDuelHistory {
  final DuelRepository _repository;

  const GetDuelHistory(this._repository);

  /// Execute query
  ///
  /// Returns list of completed duels where user participated.
  Future<Either<Failure, List<Duel>>> call(String userId) {
    return _repository.getDuelHistory(userId);
  }
}
