import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/features/duel/data/data.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
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
  getIt.registerLazySingleton(() => CreateDuel(getIt<DuelRepository>()));
  getIt.registerLazySingleton(() => AcceptDuel(getIt<DuelRepository>()));
  getIt.registerLazySingleton(() => DeclineDuel(getIt<DuelRepository>()));

  // Query Duels
  getIt.registerLazySingleton(() => GetActiveDuels(getIt<DuelRepository>()));
  getIt.registerLazySingleton(() => GetPendingDuels(getIt<DuelRepository>()));
  getIt.registerLazySingleton(() => GetDuelHistory(getIt<DuelRepository>()));

  // Real-time & Sync
  getIt.registerLazySingleton(() => WatchDuel(getIt<DuelRepository>()));
  getIt.registerLazySingleton(() => UpdateStepCount(getIt<DuelRepository>()));
  getIt.registerLazySingleton(
    () => SyncHealthData(
      getIt<HealthRepository>(),
      getIt<DuelRepository>(),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════
  // PRESENTATION (BLoCs)
  // ════════════════════════════════════════════════════════════════════════
  // TODO: Register DuelBloc when presentation layer is implemented
  // getIt.registerFactory(() => DuelBloc(...));
}
