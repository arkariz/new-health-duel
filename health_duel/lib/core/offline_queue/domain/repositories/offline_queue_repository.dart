import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';

/// Persistence contract for the offline action queue (ADR-006).
abstract class OfflineQueueRepository {
  /// Enqueues [action], first removing any existing entry with the same
  /// [QueuedAction.dedupKey] (dedup-replace semantics).
  Future<Either<Failure, void>> enqueue(QueuedAction action);

  /// Removes a single action by ID (after successful replay or a dropped
  /// conflict).
  Future<Either<Failure, void>> remove(String id);

  /// Persists an updated [QueuedAction] (e.g. after an incremented attempt
  /// count) without changing its dedup semantics.
  Future<Either<Failure, void>> update(QueuedAction action);

  /// All queued actions, sorted oldest-first (FIFO drain order).
  Future<Either<Failure, List<QueuedAction>>> getAll();

  /// Clears every queued action (used on sign-out — ADR-006 logout hygiene).
  Future<Either<Failure, void>> clear();
}
