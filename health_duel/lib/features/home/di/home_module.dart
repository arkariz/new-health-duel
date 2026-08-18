import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/challenge/domain/usecases/get_active_solo_challenge.dart';
import 'package:health_duel/features/home/presentation/bloc/home_bloc.dart';

/// Register Home feature dependencies
///
/// HomeBloc depends on the global session repository (registered by the
/// session module) and GetActiveSoloChallenge (registered by the challenge
/// module — must run before this one). Sign-out now lives in the Settings
/// screen/BLoC (features/account) — see M2.4 in the MVP launch plan.
void registerHomeModule(GetIt getIt) {
  // ═══════════════════════════════════════════════════════════════════════
  // Presentation - BLoC
  // ═══════════════════════════════════════════════════════════════════════
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      sessionRepository: getIt<SessionRepository>(),
      getActiveSoloChallenge: getIt<GetActiveSoloChallenge>(),
    ),
  );
}
