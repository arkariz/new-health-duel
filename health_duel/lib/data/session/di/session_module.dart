import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/data/data.dart';
import 'package:health_duel/data/session/domain/domain.dart';

/// Session Module Dependency Injection
///
/// Registers global session management dependencies:
/// - [SessionRepository] implementation
/// - [SignOut] use case
///
/// Must be called after auth module registers [SessionDataSource].
void registerSessionModule(GetIt getIt) {
  // ═══════════════════════════════════════════════════════════════════════════
  // Repository
  // ═══════════════════════════════════════════════════════════════════════════
  
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(
      sessionDataSource: getIt<SessionDataSource>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Use Cases
  // ═══════════════════════════════════════════════════════════════════════════

  getIt.registerFactory<SignOut>(
    () => SignOut(getIt<SessionRepository>()),
  );
}
