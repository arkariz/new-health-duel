import 'package:equatable/equatable.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';

/// Broadcast from `OfflineQueueProcessor` as the queue drains — consumed by
/// `OfflineQueueCubit` to surface app-wide snackbars (ADR-006).
sealed class OfflineQueueNotification extends Equatable {
  const OfflineQueueNotification();

  @override
  List<Object?> get props => [];
}

/// One or more queued actions replayed successfully.
final class DrainSucceeded extends OfflineQueueNotification {
  const DrainSucceeded({required this.synced, required this.pending});

  final int synced;
  final int pending;

  @override
  List<Object?> get props => [synced, pending];
}

/// A queued action failed domain validation on replay (e.g. the duel
/// expired or changed while offline) — dropped, not retried.
final class ActionConflicted extends OfflineQueueNotification {
  const ActionConflicted(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A queued action exhausted its retry attempts and was dropped.
final class ActionDropped extends OfflineQueueNotification {
  const ActionDropped(this.type);

  final OfflineActionType type;

  @override
  List<Object?> get props => [type];
}

/// The number of pending queued actions changed (used for an optional UI
/// badge — does not itself represent success or failure).
final class PendingChanged extends OfflineQueueNotification {
  const PendingChanged(this.pending);

  final int pending;

  @override
  List<Object?> get props => [pending];
}
