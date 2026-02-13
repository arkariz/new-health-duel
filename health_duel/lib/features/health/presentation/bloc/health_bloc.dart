import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';
import 'package:health_duel/features/health/presentation/bloc/health_event.dart';
import 'package:health_duel/features/health/presentation/bloc/health_state.dart';

part 'health_side_effect.dart';

/// Health Bloc - Manages step counting and health permissions
///
/// Uses Domain-Driven State Design where [HealthPermissionStatus]
/// is the single source of truth for UI state derivation.
///
/// Lifecycle:
/// 1. [HealthInitRequested] - Check permissions and platform availability
/// 2. [HealthPermissionRequested] - Request permissions from user
/// 3. [HealthRefreshRequested] - Fetch/refresh step data
///
/// State Transitions:
/// - permissionStatus drives UI view selection
/// - isLoading/isRefreshing for loading states
/// - todaySteps retained during refresh for smooth UX
class HealthBloc extends EffectBloc<HealthEvent, HealthState> {
  final CheckHealthPermissions _checkHealthPermissions;
  final RequestHealthPermissions _requestHealthPermissions;
  final GetTodaySteps _getTodaySteps;

  HealthBloc({
    required CheckHealthPermissions checkHealthPermissions,
    required RequestHealthPermissions requestHealthPermissions,
    required GetTodaySteps getTodaySteps,
  }) :  _checkHealthPermissions = checkHealthPermissions,
        _requestHealthPermissions = requestHealthPermissions,
        _getTodaySteps = getTodaySteps,
    super(HealthState.initial()) {
    // Register event handlers
    on<HealthInitRequested>(_onHealthInitRequested);
    on<HealthPermissionRequested>(_onHealthPermissionRequested);
    on<HealthRefreshRequested>(_onHealthRefreshRequested);
    on<HealthRevokeRequested>(_onHealthRevokeRequested);
  }

  /// Initialize health feature
  ///
  /// Checks permission status which internally handles platform availability.
  /// If authorized, automatically fetches step data.
  Future<void> _onHealthInitRequested(HealthInitRequested event, Emitter<HealthState> emit) async {
    emit(state.toLoading());

    // Check permissions - this handles platform availability internally
    // Returns unavailable/notSupported status if platform doesn't support health
    final permissionResult = await _checkHealthPermissions();

    permissionResult.fold(
      (failure) => _handleFailure(emit, failure),
      (status) => _handlePermissionStatus(emit, status),
    );
  }

  /// Request health permissions from user
  Future<void> _onHealthPermissionRequested(HealthPermissionRequested event, Emitter<HealthState> emit) async {
    emit(state.toLoading());

    final result = await _requestHealthPermissions();

    result.fold((failure) => _handleFailure(emit, failure), (granted) {
      if (granted) {
        emit(state.setAuthorization(true));
        add(const HealthRefreshRequested());
      } else {
        emit(state.setAuthorization(false).withEffect(_effectPermissionDeniedSnackbar));
      }
    });
  }

  /// Refresh step data
  Future<void> _onHealthRefreshRequested(HealthRefreshRequested event, Emitter<HealthState> emit) async {
    // If we have data, show refresh indicator (keep existing data)
    if (state.hasStepData) {
      emit(state.toRefreshing());
    } else {
      emit(state.toLoading());
    }

    final result = await _getTodaySteps();

    result.fold(
      (failure) {
        if (state.hasStepData) {
          // Keep existing data, show error snackbar only (effect-only emission)
          emit(state.stopLoading().withEffect(_effectRefreshFailedSnackbar(failure.message)));
        } else {
          _handleFailure(emit, failure);
        }
      },
      (stepCount) {
        emit(state.toReady(stepCount));
      },
    );
  }

  /// Revoke health permissions (for testing)
  Future<void> _onHealthRevokeRequested(HealthRevokeRequested event, Emitter<HealthState> emit) async {
    // Reset to initial state with feedback effect
    emit(state.toInitial(effect: _effectPermissionsRevokedSnackbar));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle permission status and transition to appropriate state
  void _handlePermissionStatus(Emitter<HealthState> emit, HealthPermissionStatus status) {
    switch (status) {
      case HealthPermissionStatus.authorized:
        emit(state.setAuthorization(true));
        add(const HealthRefreshRequested());

      case HealthPermissionStatus.notDetermined:
        emit(state.setAuthorization(false));

      case HealthPermissionStatus.unavailable:
        emit(state.withEffect(_effectUnavailableDialog));

      case HealthPermissionStatus.notSupported:
        emit(state.withEffect(_effectNotSupportedDialog));
    }
  }

  /// Handle platform-level failure (unavailable/not supported)
  void _handlePlatformFailure(Emitter<HealthState> emit, Failure failure) {
    final dialog = failure is HealthUnavailableFailure
      ? _effectUnavailableDialog
      : _effectNotSupportedDialog;

    emit(state.withEffect(dialog));
  }

  /// Handle failure and emit appropriate error state
  void _handleFailure(Emitter<HealthState> emit, Failure failure) {
    // Platform-level failures → show dialog
    if (failure is HealthUnavailableFailure || failure is HealthNotSupportedFailure) {
      _handlePlatformFailure(emit, failure);
      return;
    }

    // Other failures → show snackbar
    final message = switch (failure) {
      HealthPermissionFailure() => failure.message,
      NetworkFailure() => 'Network error: ${failure.message}',
      _ => failure.message,
    };
    emit(state.withEffect(_effectErrorSnackbar(message)));
  }
}
