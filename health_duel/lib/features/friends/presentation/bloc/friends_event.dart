import 'package:equatable/equatable.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

sealed class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class FriendsLoadRequested extends FriendsEvent {
  final String userId;
  const FriendsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FriendsSearchRequested extends FriendsEvent {
  final String userId;
  final String query;
  const FriendsSearchRequested({required this.userId, required this.query});

  @override
  List<Object?> get props => [userId, query];
}

class FriendAddRequested extends FriendsEvent {
  final String currentUserId;
  final UserModel targetUser;
  const FriendAddRequested({
    required this.currentUserId,
    required this.targetUser,
  });

  @override
  List<Object?> get props => [currentUserId, targetUser];
}

class FriendRemoveRequested extends FriendsEvent {
  final String currentUserId;
  final String friendId;
  const FriendRemoveRequested({
    required this.currentUserId,
    required this.friendId,
  });

  @override
  List<Object?> get props => [currentUserId, friendId];
}
