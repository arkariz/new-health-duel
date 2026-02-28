import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Get Opponents Use Case
///
/// Retrieves all other registered users as potential duel opponents.
/// Excludes the current user from the list.
class GetOpponents {
  final DuelRepository _repository;

  const GetOpponents(this._repository);

  Future<Either<Failure, List<UserModel>>> call(String excludeUserId) {
    return _repository.getOpponents(excludeUserId);
  }
}
