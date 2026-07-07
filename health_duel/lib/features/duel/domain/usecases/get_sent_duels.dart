import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Get Sent Duels Use Case
///
/// Retrieve all outgoing (sent) pending duel challenges for a user.
class GetSentDuels {

  const GetSentDuels(this._repository);
  final DuelRepository _repository;

  /// Execute query
  ///
  /// Returns list of pending duels where user is the challenger.
  Future<Either<Failure, List<Duel>>> call(String userId) {
    return _repository.getSentDuels(userId);
  }
}
