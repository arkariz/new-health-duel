import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/executor/offline_action_executor.dart';
import 'package:health_duel/core/offline_queue/domain/notification/offline_queue_notification.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';

/// Drains the offline action queue when connectivity returns (ADR-006).
///
/// Deps ([DateTime Function()] `now` and [Future<void> Function(Duration)]
/// `wait`) are injectable so tests can assert exact backoff timing without
/// real delays.
class OfflineQueueProcessor {
  OfflineQueueProcessor({
    required OfflineQueueRepository repository,
    required Stream<ConnectivityStatus> connectivityStream,
    required bool Function() isOnline,
    DateTime Function()? now,
    Future<void> Function(Duration duration)? wait,
    this.executeTimeout = const Duration(seconds: 20),
    this.maxAttempts = 6,
  })  : _repository = repository,
        _connectivityStream = connectivityStream,
        _isOnline = isOnline,
        _now = now ?? DateTime.now,
        _wait = wait ?? Future.delayed;

  final OfflineQueueRepository _repository;
  final Stream<ConnectivityStatus> _connectivityStream;
  final bool Function() _isOnline;
  final DateTime Function() _now;
  final Future<void> Function(Duration duration) _wait;
  final Duration executeTimeout;
  final int maxAttempts;

  final Map<OfflineActionType, OfflineActionExecutor> _executors = {};
  final _notificationController =
      StreamController<OfflineQueueNotification>.broadcast();

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _draining = false;

  Stream<OfflineQueueNotification> get notifications =>
      _notificationController.stream;

  /// Registers the executor for [OfflineActionExecutor.type]. Fails fast on
  /// a duplicate registration for the same type.
  void registerExecutor(OfflineActionExecutor executor) {
    if (_executors.containsKey(executor.type)) {
      throw StateError(
        'An executor is already registered for ${executor.type}',
      );
    }
    _executors[executor.type] = executor;
  }

  /// Subscribes to connectivity changes and, if already online, drains
  /// immediately. Subscribes to the stream *before* checking [_isOnline] so
  /// a status emitted between the two checks isn't missed.
  Future<void> start() async {
    _connectivitySubscription = _connectivityStream.listen((status) {
      if (status.isOnline) unawaited(drain());
    });
    if (_isOnline()) {
      unawaited(drain());
    }
  }

  /// Drains the queue FIFO (oldest `createdAt` first). Re-entrant calls are
  /// ignored via [_draining]; aborts mid-drain if connectivity drops.
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    var synced = 0;
    try {
      while (_isOnline()) {
        final allResult = await _repository.getAll();
        final actions = allResult.fold((_) => <QueuedAction>[], (a) => a);
        if (actions.isEmpty) break;

        final action = actions.first;
        await _replayOne(action, onSynced: () => synced++);
      }
    } finally {
      _draining = false;
    }

    final remainingResult = await _repository.getAll();
    final pending = remainingResult.fold((_) => 0, (a) => a.length);
    if (synced > 0) {
      _notificationController.add(DrainSucceeded(synced: synced, pending: pending));
    } else {
      _notificationController.add(PendingChanged(pending));
    }
  }

  /// Replays a single [action]. The outer [drain] loop re-checks
  /// [_isOnline] before the next iteration, so a connectivity drop during
  /// this call's backoff wait is caught there — this method never signals
  /// loop control itself.
  Future<void> _replayOne(
    QueuedAction action, {
    required void Function() onSynced,
  }) async {
    final executor = _executors[action.type];
    if (executor == null) {
      // Should never happen if DI registers an executor per type — drop
      // rather than loop forever on an unreplayable action.
      await _repository.remove(action.id);
      return;
    }

    Either<Failure, void> result;
    try {
      result = await executor.execute(action.payload).timeout(executeTimeout);
    } on TimeoutException {
      result = const Left(NetworkFailure(message: 'Offline action timed out'));
    }

    await result.fold(
      (failure) async {
        if (failure is ValidationFailure) {
          // Conflict: replaying re-ran domain validation and it failed —
          // the duel changed/expired while offline. Drop, don't retry.
          await _repository.remove(action.id);
          _notificationController.add(
            ActionConflicted(executor.conflictMessage(action.payload)),
          );
          return;
        }

        final updated = action.incrementAttempt(attemptedAt: _now());
        if (updated.attemptCount >= maxAttempts) {
          await _repository.remove(action.id);
          _notificationController.add(ActionDropped(action.type));
          return;
        }

        await _repository.update(updated);
        await _wait(_backoffFor(updated.attemptCount));
      },
      (_) async {
        await _repository.remove(action.id);
        onSynced();
      },
    );
  }

  Duration _backoffFor(int attemptCount) {
    final seconds = 2 << (attemptCount - 1); // 2, 4, 8, 16, 32, ...
    return Duration(seconds: seconds.clamp(2, 60));
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _notificationController.close();
  }
}
