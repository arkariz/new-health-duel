import 'package:equatable/equatable.dart';

/// Action types the offline queue knows how to replay (ADR-006).
///
/// Each type must have exactly one `OfflineActionExecutor` registered
/// against it before the processor starts draining.
enum OfflineActionType { acceptDuel, declineDuel, createDuel, syncStepCount }

/// A single queued write action, persisted while offline and replayed once
/// connectivity returns.
class QueuedAction extends Equatable {
  const QueuedAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.dedupKey,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastAttemptAt,
  });

  /// Sortable, unique ID — `${createdAt.microsecondsSinceEpoch}_${type.name}`.
  final String id;
  final OfflineActionType type;

  /// JSON-safe payload passed to the matching `OfflineActionExecutor`.
  final Map<String, dynamic> payload;

  /// Actions sharing a [dedupKey] replace each other on enqueue — this is
  /// also how accept/decline on the same duel cross-cancel (both use the
  /// same `duel_$duelId` key).
  final String dedupKey;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;

  static String generateId(OfflineActionType type, DateTime createdAt) =>
      '${createdAt.microsecondsSinceEpoch}_${type.name}';

  QueuedAction incrementAttempt({required DateTime attemptedAt}) => QueuedAction(
        id: id,
        type: type,
        payload: payload,
        dedupKey: dedupKey,
        createdAt: createdAt,
        attemptCount: attemptCount + 1,
        lastAttemptAt: attemptedAt,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        payload,
        dedupKey,
        createdAt,
        attemptCount,
        lastAttemptAt,
      ];
}
