import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/features/duel/data/data.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';

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

  // Query Duels
  ..registerFactory(() => GetActiveDuels(getIt<DuelRepository>()))
  ..registerFactory(() => GetPendingDuels(getIt<DuelRepository>()))
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
    ),
  )

  ..registerFactory(
    () => DuelListBloc(
      getActiveDuels: getIt<GetActiveDuels>(),
      getPendingDuels: getIt<GetPendingDuels>(),
      getDuelHistory: getIt<GetDuelHistory>(),
      acceptDuel: getIt<AcceptDuel>(),
      declineDuel: getIt<DeclineDuel>(),
    ),
  )

  ..registerFactory(
    () => CreateDuelBloc(
      getOpponents: getIt<GetOpponents>(),
      createDuel: getIt<CreateDuel>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
}
