import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/friends/domain/repositories/friend_repository.dart';

class AddFriend {
  final FriendRepository _repository;
  const AddFriend(this._repository);

  Future<Either<Failure, void>> call(String currentUserId, UserModel friend) =>
      _repository.addFriend(currentUserId, friend);
}
