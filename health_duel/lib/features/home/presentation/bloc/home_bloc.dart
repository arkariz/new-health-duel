import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/challenge/domain/usecases/get_active_solo_challenge.dart';
import 'package:health_duel/features/home/presentation/bloc/home_event.dart';
import 'package:health_duel/features/home/presentation/bloc/home_state.dart';

part 'home_side_effect.dart';

/// Home Bloc - Manages home screen state
///
/// Uses Pattern A: Single State with Clear Partitioning
///
/// State uses single [HomeState] class with:
/// - [HomeStatus] enum for state transitions
/// - Renderable data (user, errorMessage) in props
/// - Side-effect triggers (effect) NOT in props
///
/// Uses generic effects from core:
/// - [NavigateGoEffect] → For navigation after sign out
/// - [ShowSnackBarEffect] → For error/success messages
class HomeBloc extends EffectBloc<HomeEvent, HomeState> {

  HomeBloc({
    required SessionRepository sessionRepository,
    required GetActiveSoloChallenge getActiveSoloChallenge,
  })
    : _sessionRepository = sessionRepository,
      _getActiveSoloChallenge = getActiveSoloChallenge,
  super(const HomeState()) {
    on<HomeLoadUserRequested>(_onLoadUserRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }
  final SessionRepository _sessionRepository;
  final GetActiveSoloChallenge _getActiveSoloChallenge;

  /// Load current user data
  Future<void> _onLoadUserRequested(HomeLoadUserRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final result = await _sessionRepository.getCurrentUser();

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
          effect: _effectError(failure.message),
        ),
      ),
      (user) async {
        if (user == null) {
          // User not logged in, navigate to login
          emit(
            state.copyWith(
              status: HomeStatus.failure,
              errorMessage: 'Not authenticated',
              effect: _effectNavigateToLogin,
            ),
          );
          return;
        }

        final challenge = (await _getActiveSoloChallenge(user.id)).fold((_) => null, (c) => c);
        emit(state.copyWith(
          status: HomeStatus.loaded,
          user: user,
          activeChallenge: challenge,
          clearActiveChallenge: challenge == null,
          clearError: true,
        ));
      },
    );
  }

  /// Refresh user data (pull-to-refresh)
  Future<void> _onRefreshRequested(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    // Keep current state while refreshing (no loading indicator)
    final result = await _sessionRepository.getCurrentUser();

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          effect: _effectRefreshError(failure.message),
        ),
      ),
      (user) async {
        if (user == null) return;

        final challenge = (await _getActiveSoloChallenge(user.id)).fold((_) => null, (c) => c);
        emit(state.copyWith(
          status: HomeStatus.loaded,
          user: user,
          activeChallenge: challenge,
          clearActiveChallenge: challenge == null,
        ));
      },
    );
  }
}
