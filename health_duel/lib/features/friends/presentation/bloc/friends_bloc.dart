import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/friends/domain/usecases/add_friend.dart';
import 'package:health_duel/features/friends/domain/usecases/get_friends.dart';
import 'package:health_duel/features/friends/domain/usecases/remove_friend.dart';
import 'package:health_duel/features/friends/domain/usecases/search_users.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_event.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_state.dart';

part 'friends_side_effect.dart';

/// Friends BLoC — Manages friends list, search, add and remove
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004).
///
/// State flow:
/// - [FriendsInitial] → initial
/// - [FriendsLoading] → fetching friends list
/// - [FriendsLoaded]  → friends loaded (may also have search results)
/// - [FriendsError]   → failed to fetch
class FriendsBloc extends EffectBloc<FriendsEvent, FriendsState> {
  final GetFriends _getFriends;
  final AddFriend _addFriend;
  final RemoveFriend _removeFriend;
  final SearchUsers _searchUsers;

  FriendsBloc({
    required GetFriends getFriends,
    required AddFriend addFriend,
    required RemoveFriend removeFriend,
    required SearchUsers searchUsers,
  })  : _getFriends = getFriends,
        _addFriend = addFriend,
        _removeFriend = removeFriend,
        _searchUsers = searchUsers,
        super(const FriendsInitial()) {
    on<FriendsLoadRequested>(_onLoadRequested);
    on<FriendsSearchRequested>(_onSearchRequested);
    on<FriendAddRequested>(_onAddRequested);
    on<FriendRemoveRequested>(_onRemoveRequested);
  }

  Future<void> _onLoadRequested(
    FriendsLoadRequested event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoading());
    final result = await _getFriends(event.userId);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (friends) => emit(FriendsLoaded(friends: friends)),
    );
  }

  Future<void> _onSearchRequested(
    FriendsSearchRequested event,
    Emitter<FriendsState> emit,
  ) async {
    final current = state;
    if (current is! FriendsLoaded) return;

    if (event.query.trim().length < 2) {
      emit(current.copyWith(searchResults: [], isSearching: false));
      return;
    }

    emit(current.copyWith(isSearching: true));
    final result = await _searchUsers(event.query.trim(), event.userId);
    result.fold(
      (failure) => emit(current.copyWith(isSearching: false)),
      (results) => emit(current.copyWith(
        searchResults: results,
        isSearching: false,
      )),
    );
  }

  Future<void> _onAddRequested(
    FriendAddRequested event,
    Emitter<FriendsState> emit,
  ) async {
    final current = state;
    if (current is! FriendsLoaded) return;

    emit(current.copyWith(isMutating: true));
    final result = await _addFriend(event.currentUserId, event.targetUser);
    result.fold(
      (failure) => emit(current.copyWith(
        isMutating: false,
        effect: _effectError(failure.message),
      )),
      (_) {
        final updated = [event.targetUser, ...current.friends];
        emit(current.copyWith(
          friends: updated,
          isMutating: false,
          effect: _effectFriendAdded(event.targetUser.name),
        ));
      },
    );
  }

  Future<void> _onRemoveRequested(
    FriendRemoveRequested event,
    Emitter<FriendsState> emit,
  ) async {
    final current = state;
    if (current is! FriendsLoaded) return;

    // Optimistic update
    final updated =
        current.friends.where((f) => f.id != event.friendId).toList();
    emit(current.copyWith(friends: updated));

    final result =
        await _removeFriend(event.currentUserId, event.friendId);
    result.fold(
      (failure) {
        // Revert on failure
        emit(current.copyWith(effect: _effectError(failure.message)));
      },
      (_) => emit(
        (state as FriendsLoaded).copyWith(
          effect: _effectFriendRemoved(),
        ),
      ),
    );
  }
}
