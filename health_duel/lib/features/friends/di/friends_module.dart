import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/features/friends/data/datasources/friend_firestore_datasource.dart';
import 'package:health_duel/features/friends/data/repositories/friend_repository_impl.dart';
import 'package:health_duel/features/friends/domain/repositories/friend_repository.dart';
import 'package:health_duel/features/friends/domain/usecases/add_friend.dart';
import 'package:health_duel/features/friends/domain/usecases/get_friends.dart';
import 'package:health_duel/features/friends/domain/usecases/remove_friend.dart';
import 'package:health_duel/features/friends/domain/usecases/search_users.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_bloc.dart';

/// Friends Module Dependency Injection
///
/// Registers all friends-related dependencies:
/// - Data Sources: FriendFirestoreDataSource
/// - Repositories: FriendRepository
/// - Use Cases: GetFriends, AddFriend, RemoveFriend, SearchUsers
/// - BLoC: FriendsBloc
///
/// Must be called after core and session modules are registered.
void registerFriendsModule() {
  final getIt = GetIt.instance;

  // ════════════════════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════════════════════

  getIt..registerLazySingleton<FriendFirestoreDataSource>(
    () => FriendFirestoreDataSource(getIt<FirebaseFirestore>()),
  )

  // ════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ════════════════════════════════════════════════════════════════════════

  ..registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(getIt<FriendFirestoreDataSource>()),
  )

  // ════════════════════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════════════════════

  ..registerFactory(() => GetFriends(getIt<FriendRepository>()))
  ..registerFactory(() => AddFriend(getIt<FriendRepository>()))
  ..registerFactory(() => RemoveFriend(getIt<FriendRepository>()))
  ..registerFactory(() => SearchUsers(getIt<FriendRepository>()))

  // ════════════════════════════════════════════════════════════════════════
  // PRESENTATION (BLoCs)
  // ════════════════════════════════════════════════════════════════════════

  ..registerFactory(
    () => FriendsBloc(
      getFriends: getIt<GetFriends>(),
      addFriend: getIt<AddFriend>(),
      removeFriend: getIt<RemoveFriend>(),
      searchUsers: getIt<SearchUsers>(),
    ),
  );
}
