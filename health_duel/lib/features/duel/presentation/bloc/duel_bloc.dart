import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/router/routes.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

part 'duel_side_effect.dart';

/// Duel BLoC - Manages active duel state with real-time updates
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004).
///
/// Real-time Strategy (3 subscriptions):
/// 1. Firestore Listener - Real-time duel updates
/// 2. Health Sync Timer - Periodic step sync (5 minutes)
/// 3. Countdown Timer - UI countdown updates (1 second)
///
/// State flow:
/// - [DuelInitial] → Initial state
/// - [DuelLoading] → Loading duel
/// - [DuelLoaded] → Duel loaded with real-time updates
/// - [DuelError] → Error loading/watching duel
class DuelBloc extends EffectBloc<DuelEvent, DuelState> {

  DuelBloc({
    required WatchDuel watchDuel,
    required SyncHealthData syncHealthData,
    required SessionRepository sessionRepository,
    required CheckHealthPermissions checkHealthPermissions,
    required RequestHealthPermissions requestHealthPermissions,
    required CompleteDuel completeDuel,
  })  : _watchDuel = watchDuel,
        _syncHealthData = syncHealthData,
        _sessionRepository = sessionRepository,
        _checkHealthPermissions = checkHealthPermissions,
        _requestHealthPermissions = requestHealthPermissions,
        _completeDuel = completeDuel,
        super(const DuelInitial()) {
    // Register event handlers
    on<DuelLoadRequested>(_onLoadRequested);
    on<DuelUpdateSucceeded>(_onUpdateSucceeded);
    on<DuelUpdateFailed>(_onUpdateFailed);
    on<DuelHealthSyncTriggered>(_onHealthSyncTriggered);
    on<DuelCountdownTick>(_onCountdownTick);
    on<DuelCompletionDetected>(_onCompletionDetected);
    on<DuelManualRefreshRequested>(_onManualRefreshRequested);
  }
  final WatchDuel _watchDuel;
  final SyncHealthData _syncHealthData;
  final SessionRepository _sessionRepository;
  final CheckHealthPermissions _checkHealthPermissions;
  final RequestHealthPermissions _requestHealthPermissions;
  final CompleteDuel _completeDuel;

  // Three subscriptions as per design
  StreamSubscription<dynamic>? _duelStreamSubscription;
  Timer? _healthSyncTimer;
  Timer? _countdownTimer;

  // Track previous leader for lead change detection
  String? _previousLeaderId;

  // Current user ID cached from session
  String? _currentUserId;

  // Completion guards — prevent duplicate completion writes / navigations
  // when both the stream and the countdown tick detect expiry, or when the
  // stream echoes the completed document back after our own write.
  bool _completionHandled = false;
  bool _navigatedToResult = false;

  /// Load and start watching a duel
  Future<void> _onLoadRequested(
    DuelLoadRequested event,
    Emitter<DuelState> emit,
  ) async {
    emit(const DuelLoading(message: 'Loading duel...'));

    // Reset completion guards for the (re)loaded duel
    _completionHandled = false;
    _navigatedToResult = false;

    // Get current user ID from session
    final userResult = await _sessionRepository.getCurrentUser();
    final currentUser = userResult.fold(
      (_) => null,
      (user) => user,
    );

    if (currentUser == null) {
      emit(const DuelError('User not authenticated'));
      return;
    }

    _currentUserId = currentUser.id;

    // Ensure health permissions are granted before starting health sync
    final permResult = await _checkHealthPermissions();
    await permResult.fold(
      (_) async {},
      (status) async {
        if (status == HealthPermissionStatus.notDetermined) {
          await _requestHealthPermissions();
        }
      },
    );

    // Cancel existing subscriptions before starting new ones
    await _cancelSubscriptions();

    // Start Firestore real-time listener
    _duelStreamSubscription = _watchDuel(event.duelId).listen((result) {
      result.fold(
        (failure) => add(DuelUpdateFailed(failure)),
        (duel) => add(DuelUpdateSucceeded(duel)),
      );
    });

    // Start health sync timer (every 5 minutes)
    _healthSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => add(DuelHealthSyncTriggered(event.duelId)),
    );

    // Start countdown timer (every 1 second)
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const DuelCountdownTick()),
    );

    // Trigger immediate health sync on load
    add(DuelHealthSyncTriggered(event.duelId));
  }

  /// Handle successful real-time Firestore updates
  Future<void> _onUpdateSucceeded(
    DuelUpdateSucceeded event,
    Emitter<DuelState> emit,
  ) async {
    final duel = event.duel;
    final now = DateTime.now();

    // Duel authoritatively completed in Firestore (written by us, the
    // opponent, or a list sweep) — navigate to result and stop timers.
    if (duel.status == DuelStatus.completed) {
      final alreadyNavigated = _navigatedToResult;
      _completionHandled = true;
      _navigatedToResult = true;
      emit(DuelLoaded(
        duel: duel,
        currentTime: now,
        effect: alreadyNavigated ? null : _effectNavigateToResult(duel),
        lastSyncTime: state is DuelLoaded
          ? (state as DuelLoaded).lastSyncTime
          : now,
      ));
      _cancelTimers(); // Stop timers when duel completes
      return;
    }

    // Expired but Firestore still says active — finalize it client-side.
    // Keep the health sync timer alive and fall through to the normal emit
    // so the UI shows the duel while completion is written.
    _triggerCompletionIfNeeded(duel);

    // Detect lead change
    final currentLeader = duel.currentLeader;
    UiEffect? effect;

    if (_previousLeaderId != null && currentLeader != null && _previousLeaderId != currentLeader) {
      // Lead changed
      effect = _effectLeadChanged(duel);
    }

    _previousLeaderId = currentLeader;

    emit(DuelLoaded(
      duel: duel,
      lastSyncTime: state is DuelLoaded
        ? (state as DuelLoaded).lastSyncTime
        : now,
      currentTime: now,
      effect: effect,
    ));
  }

  /// Handle failed real-time Firestore updates
  Future<void> _onUpdateFailed(
    DuelUpdateFailed event,
    Emitter<DuelState> emit,
  ) async {
    final failure = event.failure;
    emit(DuelError(failure.message));
  }

  /// Sync health data from Health plugin
  Future<void> _onHealthSyncTriggered(
    DuelHealthSyncTriggered event,
    Emitter<DuelState> emit,
  ) async {
    // Don't block UI during background sync
    // Just update lastSyncTime on success

    // Early return if user ID not available
    if (_currentUserId == null) return;

    final result = await _syncHealthData(
      duelId: event.duelId,
      userId: _currentUserId!,
    );

    result.fold(
      (failure) {
        // Silently fail - health sync is best-effort
        // Could show a subtle indicator in UI
      },
      (duel) {
        if (state is DuelLoaded) {
          final currentState = state as DuelLoaded;
          emit(currentState.copyWith(
            lastSyncTime: DateTime.now(),
            duel: duel,
          ));
        }
      },
    );
  }

  /// Update countdown display
  void _onCountdownTick(
    DuelCountdownTick event,
    Emitter<DuelState> emit,
  ) {
    if (state is DuelLoaded) {
      final currentState = state as DuelLoaded;
      emit(currentState.copyWith(currentTime: DateTime.now()));

      // Check if duel expired during this tick
      _triggerCompletionIfNeeded(currentState.duel);
    }
  }

  /// Trigger client-side completion once for an expired-but-active duel
  ///
  /// Guards against duplicate [DuelCompletionDetected] dispatches from both
  /// the Firestore stream and the countdown tick racing to detect expiry.
  void _triggerCompletionIfNeeded(Duel duel) {
    if (_completionHandled || !duel.needsCompletion) return;
    _completionHandled = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    add(DuelCompletionDetected(duel.id));
  }

  /// Handle duel completion — finalize the expired duel in Firestore
  Future<void> _onCompletionDetected(
    DuelCompletionDetected event,
    Emitter<DuelState> emit,
  ) async {
    final result = await _completeDuel(event.duelId);

    result.fold(
      (failure) {
        // Fallback: notify via snackbar. Keep _completionHandled set — the
        // stream is still alive and will navigate once the opponent (or a
        // list sweep) completes the duel in Firestore.
        if (state is DuelLoaded) {
          final currentState = state as DuelLoaded;
          emit(currentState.copyWith(
            effect: _effectDuelCompleted(currentState.duel.result),
          ));
        }
      },
      (completedDuel) {
        final alreadyNavigated = _navigatedToResult;
        _navigatedToResult = true;
        _cancelTimers();
        final now = DateTime.now();
        emit(DuelLoaded(
          duel: completedDuel,
          currentTime: now,
          effect: alreadyNavigated
              ? null
              : _effectNavigateToResult(completedDuel),
          lastSyncTime: state is DuelLoaded
              ? (state as DuelLoaded).lastSyncTime
              : now,
        ));
      },
    );
  }

  /// Manual refresh requested by user
  Future<void> _onManualRefreshRequested(
    DuelManualRefreshRequested event,
    Emitter<DuelState> emit,
  ) async {
    // Trigger immediate health sync
    add(DuelHealthSyncTriggered(event.duelId));
  }

  /// Cancel all subscriptions and timers
  Future<void> _cancelSubscriptions() async {
    await _duelStreamSubscription?.cancel();
    _duelStreamSubscription = null;
    _cancelTimers();
  }

  /// Cancel only timers (used when duel completes)
  void _cancelTimers() {
    _healthSyncTimer?.cancel();
    _healthSyncTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    unawaited(_cancelSubscriptions());
    return super.close();
  }
}
