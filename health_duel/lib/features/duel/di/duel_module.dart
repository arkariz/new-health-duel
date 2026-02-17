import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/features/duel/data/data.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
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

  getIt.registerLazySingleton<DuelFirestoreDataSource>(
    () => DuelFirestoreDataSource(getIt<FirebaseFirestore>()),
  );

  // ════════════════════════════════════════════════════════════════════════
  // REPOSITORIES
  // ════════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<DuelRepository>(
    () => DuelRepositoryImpl(getIt<DuelFirestoreDataSource>()),
  );

  // ════════════════════════════════════════════════════════════════════════
  // USE CASES
  // ════════════════════════════════════════════════════════════════════════

  // Create & Manage Duels
  getIt.registerFactory(() => CreateDuel(getIt<DuelRepository>()));
  getIt.registerFactory(() => AcceptDuel(getIt<DuelRepository>()));
  getIt.registerFactory(() => DeclineDuel(getIt<DuelRepository>()));

  // Query Duels
  getIt.registerFactory(() => GetActiveDuels(getIt<DuelRepository>()));
  getIt.registerFactory(() => GetPendingDuels(getIt<DuelRepository>()));
  getIt.registerFactory(() => GetDuelHistory(getIt<DuelRepository>()));

  // Real-time & Sync
  getIt.registerFactory(() => WatchDuel(getIt<DuelRepository>()));
  getIt.registerFactory(() => UpdateStepCount(getIt<DuelRepository>()));
  getIt.registerFactory(
    () => SyncHealthData(
      getIt<HealthRepository>(),
      getIt<DuelRepository>(),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════
  // PRESENTATION (BLoCs)
  // ════════════════════════════════════════════════════════════════════════

  getIt.registerFactory(
    () => DuelBloc(
      watchDuel: getIt<WatchDuel>(),
      syncHealthData: getIt<SyncHealthData>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
}
