import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/core.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:network/network.dart';
import 'package:security/security.dart';
import 'package:storage/storage.dart';

/// Register core infrastructure dependencies
///
/// This module registers:
/// - Storage module (Hive with encryption)
/// - Network module (Dio with interceptors)
/// - Security module (AES encryption)
/// - Connectivity tracking
///
/// Uses async registration for services that require initialization.
Future<void> registerCoreModule() async {
  // 1. Initialize Storage Module (Hive + Secure Storage)
  await provideStorageModule(
    appPreferenceName: StorageKeys.appPreferences,
    keySecureStorage: StorageKeys.secureKeyStorage,
    openPreference: ({
      required call,
      required function,
      required module,
    }) => openBox(
      module: module,
      function: function,
      call: call,
    ),
  );

  // 2. Initialize Network Module (Dio)
  provideNetworkModule();

  // 3. Register DioService for feature-specific Dio instances
  // Already registered by provideNetworkModule(), but we can access it:
  // final dioService = getIt<DioService>();

  // 4. Initialize Security Module (AES encryption)
  securityModule(aesKeyPlatform: AppConfig.env.aesKeyPlatform);

  // 5. Register Connectivity Cubit
  getIt.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(Connectivity())..init(),
  );

  // Note: NetworkFlavor is abstract and should be implemented per feature.
  // Features will create their own NetworkFlavor implementations as needed.
}
