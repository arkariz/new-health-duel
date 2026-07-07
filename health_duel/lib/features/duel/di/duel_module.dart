import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/features/duel/data/data.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/friends/domain/usecases/get_friends.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

/// Duel Module Dependency Injection
///
/// Registers all duel-related dependencies:
/// - Data Sources: DuelFirestoreDataSource
/// - Repositories: DuelRepository
/// - Use Cases: CreateDuel, AcceptDuel, GetActiveDuels, etc.
///
/// Must be called after core and session modules are registered.
void registerDuelModule() {
  final getIt = GetIt.instance;

  // ════════════════════════════════════════════════════════════════════════
  // DATA SOURCES
  // ════════════════════════════════════════════════════════════════════════

  getIt..registerLazySingleton<DuelFirestoreDataSource>(
    () => DuelFirestoreDataSource(getIt<FirebaseFirestore>()),
  )

  // ════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ════════════════════════════════════════════════════════════════════════

  ..registerLazySingleton<DuelRepository>(
    () => DuelRepositoryImpl(getIt<DuelFirestoreDataSource>()),
  )

  // ════════════════════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════════════════════

  // Create & Manage Duels
  ..registerFactory(() => CreateDuel(getIt<DuelRepository>()))
  ..registerFactory(() => AcceptDuel(getIt<DuelRepository>()))
  ..registerFactory(() => DeclineDuel(getIt<DuelRepository>()))
  ..registerFactory(() => CompleteDuel(getIt<DuelRepository>()))
  ..registerFactory(() => ExpirePendingDuel(getIt<DuelRepository>()))

  // Query Duels
  ..registerFactory(() => GetActiveDuels(getIt<DuelRepository>()))
  ..registerFactory(() => GetPendingDuels(getIt<DuelRepository>()))
  ..registerFactory(() => GetSentDuels(getIt<DuelRepository>()))
  ..registerFactory(() => GetDuelHistory(getIt<DuelRepository>()))
  ..registerFactory(() => GetOpponents(getIt<DuelRepository>()))

  // Real-time & Sync
  ..registerFactory(() => WatchDuel(getIt<DuelRepository>()))
  ..registerFactory(() => UpdateStepCount(getIt<DuelRepository>()))
  ..registerFactory(
    () => SyncHealthData(
      getIt<HealthRepository>(),
      getIt<DuelRepository>(),
    ),
  )

  // ════════════════════════════════════════════════════════════════════════
  // PRESENTATION (BLoCs)
  // ════════════════════════════════════════════════════════════════════════

  ..registerFactory(
    () => DuelBloc(
      watchDuel: getIt<WatchDuel>(),
      syncHealthData: getIt<SyncHealthData>(),
      sessionRepository: getIt<SessionRepository>(),
      checkHealthPermissions: getIt<CheckHealthPermissions>(),
      requestHealthPermissions: getIt<RequestHealthPermissions>(),
      completeDuel: getIt<CompleteDuel>(),
    ),
  )

  ..registerFactory(
    () => DuelListBloc(
      getActiveDuels: getIt<GetActiveDuels>(),
      getPendingDuels: getIt<GetPendingDuels>(),
      getSentDuels: getIt<GetSentDuels>(),
      getDuelHistory: getIt<GetDuelHistory>(),
      acceptDuel: getIt<AcceptDuel>(),
      declineDuel: getIt<DeclineDuel>(),
      syncHealthData: getIt<SyncHealthData>(),
      checkHealthPermissions: getIt<CheckHealthPermissions>(),
      completeDuel: getIt<CompleteDuel>(),
      expirePendingDuel: getIt<ExpirePendingDuel>(),
    ),
  )

  ..registerFactory(
    () => CreateDuelBloc(
      getFriends: getIt<GetFriends>(),
      getOpponents: getIt<GetOpponents>(),
      createDuel: getIt<CreateDuel>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
}
