import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';

/// Clears all queued actions — called on sign-out (ADR-006 logout hygiene).
///
/// Queued actions carry a `userId` in their payload; replaying them after
/// switching accounts would apply the wrong user's intent.
class ClearOfflineQueue {
  const ClearOfflineQueue(this._repository);

  final OfflineQueueRepository _repository;

  Future<Either<Failure, void>> call() => _repository.clear();
}
