import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:health_duel/core/di/core_module.dart';
import 'package:health_duel/features/health/data/datasources/datasources.dart';
import 'package:health_duel/features/health/data/repositories/repositories.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';
import 'package:health_duel/features/health/presentation/bloc/health_bloc.dart';

/// Health Module Dependency Injection
///
/// Registers all health feature dependencies:
/// - External Services: Health plugin
/// - Data Sources: HealthPlatformDataSource
/// - Repositories: HealthRepository
/// - Use Cases: CheckHealthPermissions, RequestHealthPermissions, GetTodaySteps, etc.
/// - Presentation: HealthBloc
///
/// Must be called after [registerCoreModule] completes.
void registerHealthModule(GetIt getIt) {
  // ========================
  // External Services
  // ========================

  if (!getIt.isRegistered<Health>()) {
    getIt.registerLazySingleton<Health>(Health.new);
  }

  // ========================
  // Data Sources
  // ========================

  getIt..registerLazySingleton<HealthPlatformDataSource>(
    () => HealthPlatformDataSourceImpl(health: getIt<Health>()),
  )

  // ========================
  // Repositories
  // ========================

  ..registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(getIt<HealthPlatformDataSource>()),
  )

  // ========================
  // Use Cases
  // ========================

  ..registerFactory<CheckHealthPermissions>(
    () => CheckHealthPermissions(getIt<HealthRepository>()),
  )

  ..registerFactory<RequestHealthPermissions>(
    () => RequestHealthPermissions(getIt<HealthRepository>()),
  )

  ..registerFactory<GetTodaySteps>(
    () => GetTodaySteps(getIt<HealthRepository>()),
  )

  ..registerFactory<CheckHealthConnectAvailable>(
    () => CheckHealthConnectAvailable(getIt<HealthRepository>()),
  )

  // ========================
  // Bloc
  // ========================

  // Factory: Create new instance each time (for route-scoped blocs)
  ..registerFactory<HealthBloc>(
    () => HealthBloc(
      checkHealthPermissions: getIt<CheckHealthPermissions>(),
      requestHealthPermissions: getIt<RequestHealthPermissions>(),
      getTodaySteps: getIt<GetTodaySteps>(),
    ),
  );
}
