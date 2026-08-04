import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/config/firebase_options.dart';
import 'package:health_duel/core/di/core_module.dart';
import 'package:health_duel/core/offline_queue/application/offline_queue_processor.dart';
import 'package:health_duel/core/offline_queue/di/offline_queue_module.dart';
import 'package:health_duel/core/router/app_router.dart';
import 'package:health_duel/data/session/di/session_module.dart';
import 'package:health_duel/features/auth/di/auth_module.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/duel/data/background/health_sync_background_task.dart';
import 'package:health_duel/features/duel/di/duel_module.dart';
import 'package:health_duel/features/friends/di/friends_module.dart';
import 'package:health_duel/features/health/di/health_module.dart';
import 'package:health_duel/features/home/di/home_module.dart';
import 'package:workmanager/workmanager.dart';

/// GetIt instance - Service Locator for Dependency Injection
final GetIt getIt = GetIt.instance;

/// Initialize dependencies the first frame cannot run without.
///
/// This is Step 1 of app startup — **must** be awaited in `main()` before
/// `runApp()`, because the router and `AuthBloc` are resolved from `getIt`
/// synchronously right after this returns. Nothing here should be deferred:
/// if a dependency registered here isn't ready, the app literally cannot
/// build its first frame (no router, no auth state, no theme).
///
/// Order of initialization:
/// 1. Core infrastructure (Storage, Network, Security)
/// 2. Feature modules (Auth, etc.)
/// 3. Router (requires AuthBloc for redirect logic)
///
/// See [warmUpDependencies] for Step 2 — dependencies that are safe to
/// finish initializing after the first frame has already been requested.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   AppConfig.init(Environment.dev);
///   await initializeDependencies();   // Step 1 — must complete first
///   warmUpDependencies();             // Step 2 — fire-and-forget
///   runApp(const HealthDuelApp());
/// }
/// ```
Future<void> initializeDependencies() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Initialize Core Infrastructure (Storage, Network, Security)
  await registerCoreModule();

  // Wait for all async registrations to complete
  await getIt.allReady();

  // 2. Register Feature Modules
  // Session module: global session use cases & repository
  registerSessionModule(getIt);

  // Auth feature: data sources, repositories, use cases
  registerAuthModule();

  // Home feature: HomeBloc (depends on auth use cases)
  registerHomeModule(getIt);

  // Health feature: step counting, health permissions
  registerHealthModule(getIt);

  // Friends feature: friend management and user search
  registerFriendsModule();

  // Offline action queue (ADR-006) — needs HiveAesCipher (available after
  // getIt.allReady() above) and must register before the duel module so
  // duel offline executors can attach to the processor.
  await registerOfflineQueueModule();

  // Duel feature: duel management, step competitions (Phase 4)
  registerDuelModule();

  // 3. Register Router (needs AuthBloc for redirect logic)
  _registerRouter();

  // TODO(rizky): Future phases - Register additional feature modules
  // registerProfileModule();
}

/// Register GoRouter with auth-aware redirects
void _registerRouter() {
  getIt.registerSingleton<GoRouter>(
    createAppRouter(getIt<AuthBloc>()),
  );
}

/// Warm up dependencies the first frame does *not* need to wait on.
///
/// This is Step 2 of app startup — called right after
/// [initializeDependencies] in `main()`, but deliberately **not** awaited.
/// Each item here manages its own completion independently and is safe to
/// still be finishing after `runApp()` returns, because nothing in the
/// initial UI reads its result synchronously:
/// - Draining the offline action queue (ADR-006) is a background process
///   that only matters once it produces a notification; `OfflineQueueCubit`
///   is already listening by the time anything could complete.
/// - Registering the `workmanager` background isolate entry point only
///   matters for a periodic task that fires minutes later at the earliest.
///
/// Must be called strictly after [initializeDependencies] — both rely on
/// `getIt` registrations completed there (e.g. `OfflineQueueProcessor`).
void warmUpDependencies() {
  // Start draining any actions queued from a previous session/offline
  // period (ADR-006).
  unawaited(getIt<OfflineQueueProcessor>().start());

  // Register the background isolate entry point for periodic step sync
  // (see WorkmanagerBackgroundSyncController).
  unawaited(Workmanager().initialize(callbackDispatcher));
}

/// Reset all dependencies (mainly for testing)
///
/// WARNING: Only use this in test files. Never call in production code.
void resetDependencies() {
  unawaited(getIt.reset());
}
