import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/friends/data/datasources/friend_firestore_datasource.dart';
import 'package:health_duel/features/friends/domain/repositories/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendFirestoreDataSource _dataSource;
  const FriendRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<UserModel>>> getFriends(String userId) async {
    try {
      return Right(await _dataSource.getFriends(userId));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load friends: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addFriend(
    String currentUserId,
    UserModel friend,
  ) async {
    try {
      await _dataSource.addFriend(currentUserId, friend);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add friend: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend(
    String currentUserId,
    String friendId,
  ) async {
    try {
      await _dataSource.removeFriend(currentUserId, friendId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove friend: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(
    String query,
    String excludeUserId,
  ) async {
    try {
      return Right(await _dataSource.searchUsers(query, excludeUserId));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search users: $e'));
    }
  }
}
