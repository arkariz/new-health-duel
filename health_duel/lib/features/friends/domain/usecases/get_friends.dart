import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/friends/domain/repositories/friend_repository.dart';

class GetFriends {
  final FriendRepository _repository;
  const GetFriends(this._repository);

  Future<Either<Failure, List<UserModel>>> call(String userId) =>
      _repository.getFriends(userId);
}
