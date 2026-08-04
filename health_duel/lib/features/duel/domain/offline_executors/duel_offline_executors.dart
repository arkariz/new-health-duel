import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/executor/offline_action_executor.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Replays a queued accept via the existing [AcceptDuel] use case (ADR-006).
///
/// Payload: `{duelId}`.
class AcceptDuelExecutor implements OfflineActionExecutor {
  const AcceptDuelExecutor(this._acceptDuel);

  final AcceptDuel _acceptDuel;

  @override
  OfflineActionType get type => OfflineActionType.acceptDuel;

  @override
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload) async {
    final result = await _acceptDuel(payload['duelId'] as String);
    return result.fold(Left.new, (_) => const Right(null));
  }

  @override
  String conflictMessage(Map<String, dynamic> payload) =>
      'This duel invitation is no longer available — it may have expired '
      'or already been responded to.';
}

/// Replays a queued decline/cancel via the existing [DeclineDuel] use case
/// (ADR-006).
///
/// Payload: `{duelId}`. The payload can't distinguish "decline" from
/// "cancel" (both call [DeclineDuel]), so the conflict message stays
/// neutral.
class DeclineDuelExecutor implements OfflineActionExecutor {
  const DeclineDuelExecutor(this._declineDuel);

  final DeclineDuel _declineDuel;

  @override
  OfflineActionType get type => OfflineActionType.declineDuel;

  @override
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload) async {
    return _declineDuel(payload['duelId'] as String);
  }

  @override
  String conflictMessage(Map<String, dynamic> payload) =>
      'This duel invitation is no longer available.';
}

/// Replays a queued challenge via the existing [CreateDuel] use case
/// (ADR-006).
///
/// Payload: `{challengerId, challengedId, challengerName, challengedName}`.
class CreateDuelExecutor implements OfflineActionExecutor {
  const CreateDuelExecutor(this._createDuel);

  final CreateDuel _createDuel;

  @override
  OfflineActionType get type => OfflineActionType.createDuel;

  @override
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload) async {
    final result = await _createDuel(
      challengerId: payload['challengerId'] as String,
      challengedId: payload['challengedId'] as String,
      challengerName: payload['challengerName'] as String,
      challengedName: payload['challengedName'] as String,
    );
    return result.fold(Left.new, (_) => const Right(null));
  }

  @override
  String conflictMessage(Map<String, dynamic> payload) =>
      'Could not send your challenge to '
      "${payload['challengedName']} — you may already have an active duel "
      'with them.';
}

/// Replays a queued step sync via the existing [SyncHealthData] use case
/// (ADR-006). Re-fetches fresh steps from the platform at replay time, so
/// concurrent replays are naturally latest-wins.
///
/// Payload: `{duelId, userId}`.
class SyncStepCountExecutor implements OfflineActionExecutor {
  const SyncStepCountExecutor(this._syncHealthData);

  final SyncHealthData _syncHealthData;

  @override
  OfflineActionType get type => OfflineActionType.syncStepCount;

  @override
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload) async {
    final result = await _syncHealthData(
      duelId: payload['duelId'] as String,
      userId: payload['userId'] as String,
    );
    return result.fold(Left.new, (_) => const Right(null));
  }

  @override
  String conflictMessage(Map<String, dynamic> payload) =>
      'Could not sync your step count — the duel may have ended.';
}
