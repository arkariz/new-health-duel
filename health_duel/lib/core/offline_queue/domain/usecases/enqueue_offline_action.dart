import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';

/// Queues a write action for later replay (ADR-006).
///
/// Dedup-replace and accept↔decline cross-cancel both fall out of
/// [OfflineQueueRepository.enqueue]'s dedup-by-key semantics — no special
/// casing needed here, as long as callers pass the dedup keys documented in
/// ADR-006 (e.g. `duel_$duelId` for both accept and decline on the same
/// duel).
class EnqueueOfflineAction {
  const EnqueueOfflineAction(this._repository);

  final OfflineQueueRepository _repository;

  Future<Either<Failure, void>> call({
    required OfflineActionType type,
    required Map<String, dynamic> payload,
    required String dedupKey,
  }) {
    final now = DateTime.now();
    final action = QueuedAction(
      id: QueuedAction.generateId(type, now),
      type: type,
      payload: payload,
      dedupKey: dedupKey,
      createdAt: now,
    );
    return _repository.enqueue(action);
  }
}
