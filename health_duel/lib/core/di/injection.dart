import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/di/core_module.dart';
import 'package:health_duel/core/router/app_router.dart';
import 'package:health_duel/data/session/di/session_module.dart';
import 'package:health_duel/features/auth/di/auth_module.dart';
import 'package:health_duel/core/config/firebase_options.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/duel/di/duel_module.dart';
import 'package:health_duel/features/health/di/health_module.dart';
import 'package:health_duel/features/home/di/home_module.dart';

/// GetIt instance - Service Locator for Dependency Injection
final getIt = GetIt.instance;

/// Initialize all application dependencies
///
/// This is the main entry point for dependency injection setup.
/// Must be called in main() before runApp().
///
/// Order of initialization:
/// 1. Core infrastructure (Storage, Network, Security)
/// 2. Feature modules (Auth, etc.)
/// 3. Router (requires AuthBloc for redirect logic)
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   AppConfig.init(Environment.dev);
///   await initializeDependencies();
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

  // Duel feature: duel management, step competitions (Phase 4)
  registerDuelModule();

  // 3. Register Router (needs AuthBloc for redirect logic)
  _registerRouter();

  // TODO: Future phases - Register additional feature modules
  // registerProfileModule();
}

/// Register GoRouter with auth-aware redirects
void _registerRouter() {
  getIt.registerSingleton<GoRouter>(
    createAppRouter(getIt<AuthBloc>()),
  );
}

/// Reset all dependencies (mainly for testing)
///
/// WARNING: Only use this in test files. Never call in production code.
void resetDependencies() {
  getIt.reset();
}
