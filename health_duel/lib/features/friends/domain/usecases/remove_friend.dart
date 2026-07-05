import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/friends/domain/repositories/friend_repository.dart';

class RemoveFriend {
  final FriendRepository _repository;
  const RemoveFriend(this._repository);

  Future<Either<Failure, void>> call(String currentUserId, String friendId) =>
      _repository.removeFriend(currentUserId, friendId);
}
