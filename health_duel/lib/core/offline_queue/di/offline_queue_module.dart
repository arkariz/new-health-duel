import 'package:exception/exception.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/core/config/storage_keys.dart';
import 'package:health_duel/core/offline_queue/application/offline_queue_processor.dart';
import 'package:health_duel/core/offline_queue/data/datasources/offline_queue_local_datasource.dart';
import 'package:health_duel/core/offline_queue/data/repositories/offline_queue_repository_impl.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';
import 'package:health_duel/core/offline_queue/domain/usecases/clear_offline_queue.dart';
import 'package:health_duel/core/offline_queue/domain/usecases/enqueue_offline_action.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_cubit.dart';
import 'package:health_duel/core/offline_queue/presentation/offline_aware_action.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:storage/storage.dart';

/// Registers the offline action queue module (ADR-006).
///
/// Must run after `registerCoreModule()` + `getIt.allReady()` (needs
/// `HiveAesCipher` to be resolvable) and before `registerDuelModule()`
/// (which registers duel executors against the [OfflineQueueProcessor]).
Future<void> registerOfflineQueueModule() async {
  final getIt = GetIt.instance;

  final database = await Database.init<String>(
    name: StorageKeys.offlineQueueActions,
    openDatabase: openBox,
    encryptionCipher: await getHiveAesCipher(),
  );

  getIt..registerLazySingleton<OfflineQueueLocalDataSource>(
    () => OfflineQueueLocalDataSource(database),
  )
  ..registerLazySingleton<OfflineQueueRepository>(
    () => OfflineQueueRepositoryImpl(getIt<OfflineQueueLocalDataSource>()),
  )
  ..registerFactory(() => EnqueueOfflineAction(getIt<OfflineQueueRepository>()))
  ..registerFactory(() => ClearOfflineQueue(getIt<OfflineQueueRepository>()))
  ..registerFactory(
    () => OfflineAwareAction(
      getIt<ConnectivityCubit>(),
      getIt<EnqueueOfflineAction>(),
    ),
  )
  ..registerLazySingleton<OfflineQueueProcessor>(
    () => OfflineQueueProcessor(
      repository: getIt<OfflineQueueRepository>(),
      connectivityStream: getIt<ConnectivityCubit>().stream,
      isOnline: () => getIt<ConnectivityCubit>().isOnline,
    ),
  )
  ..registerLazySingleton<OfflineQueueCubit>(
    () => OfflineQueueCubit(
      processor: getIt<OfflineQueueProcessor>(),
      repository: getIt<OfflineQueueRepository>(),
    ),
  );
}
