import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/challenge/domain/domain.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_event.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_state.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

part 'challenge_side_effect.dart';

/// Solo Challenge BLoC — the "solo spine": one person's 24h target.
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004). Mirrors
/// DuelBloc's real-time strategy (Firestore listener + health sync timer
/// + countdown timer) minus everything that exists only because a duel
/// has two writers: no offline queue, no background WorkManager sync, no
/// active-challenge pointer. A challenge only makes progress while this
/// screen is open — acceptable per the MVP plan's explicit simplicity
/// scope for this feature.
///
/// State flow:
/// - [ChallengeInitial] → initial
/// - [ChallengeLoading] → checking for an active challenge
/// - [ChallengeLoaded] → `challenge: null` shows the set-target form;
///   non-null shows live progress
/// - [ChallengeError] → failed to load
class SoloChallengeBloc extends EffectBloc<ChallengeEvent, ChallengeState> {
  SoloChallengeBloc({
    required GetActiveSoloChallenge getActiveSoloChallenge,
    required StartSoloChallenge startSoloChallenge,
    required WatchSoloChallenge watchSoloChallenge,
    required SyncSoloChallengeHealthData syncHealthData,
    required CompleteSoloChallenge completeSoloChallenge,
    required RecordChallengeCompletion recordChallengeCompletion,
    required SessionRepository sessionRepository,
    required CheckHealthPermissions checkHealthPermissions,
    required RequestHealthPermissions requestHealthPermissions,
  })  : _getActiveSoloChallenge = getActiveSoloChallenge,
        _startSoloChallenge = startSoloChallenge,
        _watchSoloChallenge = watchSoloChallenge,
        _syncHealthData = syncHealthData,
        _completeSoloChallenge = completeSoloChallenge,
        _recordChallengeCompletion = recordChallengeCompletion,
        _sessionRepository = sessionRepository,
        _checkHealthPermissions = checkHealthPermissions,
        _requestHealthPermissions = requestHealthPermissions,
        super(const ChallengeInitial()) {
    on<ChallengeLoadRequested>(_onLoadRequested);
    on<ChallengeStartRequested>(_onStartRequested);
    on<ChallengeUpdateSucceeded>(_onUpdateSucceeded);
    on<ChallengeUpdateFailed>(_onUpdateFailed);
    on<ChallengeHealthSyncTriggered>(_onHealthSyncTriggered);
    on<ChallengeCountdownTick>(_onCountdownTick);
    on<ChallengeCompletionDetected>(_onCompletionDetected);
    on<ChallengeManualRefreshRequested>(_onManualRefreshRequested);
  }

  final GetActiveSoloChallenge _getActiveSoloChallenge;
  final StartSoloChallenge _startSoloChallenge;
  final WatchSoloChallenge _watchSoloChallenge;
  final SyncSoloChallengeHealthData _syncHealthData;
  final CompleteSoloChallenge _completeSoloChallenge;
  final RecordChallengeCompletion _recordChallengeCompletion;
  final SessionRepository _sessionRepository;
  final CheckHealthPermissions _checkHealthPermissions;
  final RequestHealthPermissions _requestHealthPermissions;

  StreamSubscription<dynamic>? _challengeStreamSubscription;
  Timer? _healthSyncTimer;
  Timer? _countdownTimer;
  String? _currentUserId;
  bool _completionHandled = false;

  Future<void> _onLoadRequested(
    ChallengeLoadRequested event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading());
    await _cancelSubscriptions();
    _completionHandled = false;

    final userResult = await _sessionRepository.getCurrentUser();
    final user = userResult.fold((_) => null, (u) => u);
    if (user == null) {
      emit(const ChallengeError('User not authenticated'));
      return;
    }
    _currentUserId = user.id;

    final activeResult = await _getActiveSoloChallenge(user.id);
    activeResult.fold(
      (failure) => emit(ChallengeError(failure.message)),
      (challenge) {
        if (challenge == null) {
          emit(ChallengeLoaded(currentTime: DateTime.now()));
          return;
        }
        emit(ChallengeLoaded(challenge: challenge, currentTime: DateTime.now()));
        _startWatching(user.id, challenge.id);
      },
    );
  }

  Future<void> _onStartRequested(
    ChallengeStartRequested event,
    Emitter<ChallengeState> emit,
  ) async {
    final current = state;
    if (current is! ChallengeLoaded) return;
    final userId = _currentUserId;
    if (userId == null) return;

    emit(current.copyWith(isStarting: true));
    final result = await _startSoloChallenge(userId: userId, target: event.target);

    result.fold(
      (failure) => emit(current.copyWith(
        isStarting: false,
        effect: _effectError(failure.message),
      )),
      (challenge) {
        emit(ChallengeLoaded(challenge: challenge, currentTime: DateTime.now()));
        _startWatching(userId, challenge.id);
      },
    );
  }

  /// Start (or restart) the Firestore listener + sync/countdown timers for
  /// [challengeId], after checking Health Connect permission.
  void _startWatching(String userId, String challengeId) {
    unawaited(() async {
      await _cancelSubscriptions();

      final permResult = await _checkHealthPermissions();
      await permResult.fold(
        (_) async {},
        (status) async {
          if (status == HealthPermissionStatus.notDetermined) {
            await _requestHealthPermissions();
          }
        },
      );

      _challengeStreamSubscription =
          _watchSoloChallenge(userId: userId, challengeId: challengeId).listen((result) {
        result.fold(
          (failure) => add(ChallengeUpdateFailed(failure)),
          (challenge) => add(ChallengeUpdateSucceeded(challenge)),
        );
      });

      _healthSyncTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => add(ChallengeHealthSyncTriggered(challengeId)),
      );

      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const ChallengeCountdownTick()),
      );

      add(ChallengeHealthSyncTriggered(challengeId));
    }());
  }

  Future<void> _onUpdateSucceeded(
    ChallengeUpdateSucceeded event,
    Emitter<ChallengeState> emit,
  ) async {
    final challenge = event.challenge;

    if (challenge.status.isFinal) {
      final alreadyHandled = _completionHandled;
      _completionHandled = true;
      emit(ChallengeLoaded(
        challenge: challenge,
        currentTime: DateTime.now(),
        lastSyncTime: state is ChallengeLoaded ? (state as ChallengeLoaded).lastSyncTime : null,
        effect: alreadyHandled ? null : _effectChallengeCompleted(challenge),
      ));
      _cancelTimers();
      if (!alreadyHandled) {
        unawaited(_recordChallengeCompletion(metTarget: challenge.metTarget));
      }
      return;
    }

    _triggerCompletionIfNeeded(challenge);

    emit(ChallengeLoaded(
      challenge: challenge,
      currentTime: DateTime.now(),
      lastSyncTime: state is ChallengeLoaded ? (state as ChallengeLoaded).lastSyncTime : null,
    ));
  }

  void _onUpdateFailed(ChallengeUpdateFailed event, Emitter<ChallengeState> emit) {
    emit(ChallengeError(event.failure.message));
  }

  Future<void> _onHealthSyncTriggered(
    ChallengeHealthSyncTriggered event,
    Emitter<ChallengeState> emit,
  ) async {
    final current = state;
    if (current is! ChallengeLoaded || current.challenge == null) return;
    final userId = _currentUserId;
    if (userId == null) return;

    final result = await _syncHealthData(
      userId: userId,
      challengeId: event.challengeId,
      startTime: current.challenge!.startTime,
      endTime: current.challenge!.endTime,
    );

    result.fold(
      (failure) {
        // Silent — best-effort, same as duel health sync.
      },
      (challenge) {
        if (state is ChallengeLoaded) {
          emit((state as ChallengeLoaded).copyWith(
            challenge: challenge,
            lastSyncTime: DateTime.now(),
          ));
        }
      },
    );
  }

  void _onCountdownTick(ChallengeCountdownTick event, Emitter<ChallengeState> emit) {
    final current = state;
    if (current is! ChallengeLoaded || current.challenge == null) return;
    emit(current.copyWith(currentTime: DateTime.now()));
    _triggerCompletionIfNeeded(current.challenge!);
  }

  void _triggerCompletionIfNeeded(SoloChallenge challenge) {
    if (_completionHandled || !challenge.needsCompletion) return;
    _completionHandled = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    add(ChallengeCompletionDetected(challenge.id));
  }

  Future<void> _onCompletionDetected(
    ChallengeCompletionDetected event,
    Emitter<ChallengeState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final result = await _completeSoloChallenge(userId: userId, challengeId: event.challengeId);

    result.fold(
      (failure) {
        if (state is ChallengeLoaded) {
          emit((state as ChallengeLoaded).copyWith(effect: _effectError(failure.message)));
        }
      },
      (challenge) {
        _cancelTimers();
        emit(ChallengeLoaded(
          challenge: challenge,
          currentTime: DateTime.now(),
          lastSyncTime: state is ChallengeLoaded ? (state as ChallengeLoaded).lastSyncTime : null,
          effect: _effectChallengeCompleted(challenge),
        ));
        unawaited(_recordChallengeCompletion(metTarget: challenge.metTarget));
      },
    );
  }

  void _onManualRefreshRequested(
    ChallengeManualRefreshRequested event,
    Emitter<ChallengeState> emit,
  ) {
    add(ChallengeHealthSyncTriggered(event.challengeId));
  }

  Future<void> _cancelSubscriptions() async {
    await _challengeStreamSubscription?.cancel();
    _challengeStreamSubscription = null;
    _cancelTimers();
  }

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
