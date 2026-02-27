import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/data/session/domain/domain.dart';
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
  final SessionRepository _sessionRepository;
  final SignOut _signOut;

  HomeBloc({
    required SessionRepository sessionRepository, 
    required SignOut signOut,
  })
    : _sessionRepository = sessionRepository,
      _signOut = signOut,
  super(const HomeState()) {
    on<HomeLoadUserRequested>(_onLoadUserRequested);
    on<HomeSignOutRequested>(_onSignOutRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeNavigateToHealthRequested>(_onNavigateToHealthRequested);
  }

  /// Load current user data
  Future<void> _onLoadUserRequested(HomeLoadUserRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final result = await _sessionRepository.getCurrentUser();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
          effect: _effectError(failure.message),
        ),
      ),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: HomeStatus.loaded, user: user, clearError: true));
        } else {
          // User not logged in, navigate to login
          emit(
            state.copyWith(
              status: HomeStatus.failure,
              errorMessage: 'Not authenticated',
              effect: _effectNavigateToLogin,
            ),
          );
        }
      },
    );
  }

  /// Sign out and navigate to login
  Future<void> _onSignOutRequested(HomeSignOutRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await _signOut();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.loaded, // Stay on loaded state
          effect: _effectError(failure.message),
        ),
      ),
      (_) => emit(
        state.copyWith(status: HomeStatus.initial, clearUser: true, effect: _effectNavigateToLogin),
      ),
    );
  }

  /// Refresh user data (pull-to-refresh)
  Future<void> _onRefreshRequested(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    // Keep current state while refreshing (no loading indicator)
    final result = await _sessionRepository.getCurrentUser();

    result.fold(
      (failure) => emit(
        state.copyWith(
          effect: _effectRefreshError(failure.message),
        ),
      ),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: HomeStatus.loaded, user: user));
        }
      },
    );
  }

  /// Navigate to health feature
  void _onNavigateToHealthRequested(HomeNavigateToHealthRequested event, Emitter<HomeState> emit) {
    emit(state.withEffect(_effectNavigateToHealth));
  }
}
