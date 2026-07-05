import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

abstract class FriendRepository {
  Future<Either<Failure, List<UserModel>>> getFriends(String userId);
  Future<Either<Failure, void>> addFriend(String currentUserId, UserModel friend);
  Future<Either<Failure, void>> removeFriend(String currentUserId, String friendId);
  Future<Either<Failure, List<UserModel>>> searchUsers(String query, String excludeUserId);
}
