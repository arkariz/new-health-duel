import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/home/presentation/bloc/home_bloc.dart';

/// Register Home feature dependencies
///
/// HomeBloc depends on global session use cases (GetCurrentUser, SignOut)
/// which are registered by session module.
void registerHomeModule(GetIt getIt) {
  // ═══════════════════════════════════════════════════════════════════════
  // Presentation - BLoC
  // ═══════════════════════════════════════════════════════════════════════
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      sessionRepository: getIt<SessionRepository>(),
      signOut: getIt<SignOut>(),
    ),
  );
}
