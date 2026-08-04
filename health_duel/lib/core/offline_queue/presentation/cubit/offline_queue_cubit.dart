import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/offline_queue/application/offline_queue_processor.dart';
import 'package:health_duel/core/offline_queue/domain/notification/offline_queue_notification.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_state.dart';

/// App-wide surface for [OfflineQueueProcessor] notifications (ADR-006).
///
/// Provided once at the app root (see `app.dart`) via an `EffectListener`,
/// so any queued-action outcome (synced, conflicted, dropped) shows a
/// snackbar regardless of which screen is currently active. Only ever emits
/// [ShowSnackBarEffect] — never navigation, since this cubit lives above
/// GoRouter's scope in the widget tree.
class OfflineQueueCubit extends Cubit<OfflineQueueState> {
  OfflineQueueCubit({
    required OfflineQueueProcessor processor,
    required OfflineQueueRepository repository,
  })  : _processor = processor,
        _repository = repository,
        super(const OfflineQueueState()) {
    _subscription = _processor.notifications.listen(_onNotification);
  }

  final OfflineQueueProcessor _processor;
  final OfflineQueueRepository _repository;
  StreamSubscription<OfflineQueueNotification>? _subscription;

  Future<void> _onNotification(OfflineQueueNotification notification) async {
    final pending = await _pendingCount();

    switch (notification) {
      case DrainSucceeded(:final synced):
        _emitEffect(
          pendingCount: pending,
          effect: ShowSnackBarEffect(
            message: synced == 1
                ? "You're back online — 1 action synced."
                : "You're back online — $synced actions synced.",
            severity: FeedbackSeverity.success,
          ),
        );
      case ActionConflicted(:final message):
        _emitEffect(
          pendingCount: pending,
          effect: ShowSnackBarEffect(
            message: message,
            severity: FeedbackSeverity.warning,
          ),
        );
      case ActionDropped():
        _emitEffect(
          pendingCount: pending,
          effect: ShowSnackBarEffect(
            message: "One of your queued actions couldn't be completed and "
                'was removed.',
            severity: FeedbackSeverity.error,
          ),
        );
      case PendingChanged():
        emit(state.copyWith(pendingCount: pending));
    }
  }

  /// Emits `clearEffect()` before the new effect so two notifications with
  /// otherwise-identical state still both reach `EffectListener` — the
  /// established convention for long-lived cubits/blocs in this codebase.
  void _emitEffect({required int pendingCount, required ShowSnackBarEffect effect}) {
    emit(state.clearEffect());
    emit(state.copyWith(pendingCount: pendingCount, effect: effect));
  }

  Future<int> _pendingCount() async {
    final result = await _repository.getAll();
    return result.fold((_) => state.pendingCount, (actions) => actions.length);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
