import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/usecases/enqueue_offline_action.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';

/// Centralizes the "check connectivity, then either run the real use case
/// or queue it" pattern (ADR-005) so blocs don't each hand-roll the same
/// `if (_connectivity.isOffline) { enqueue...; return; }` branch.
///
/// The check must stay proactive (before the use case call), never
/// reactive: `DuelRepositoryImpl` maps every exception to `ServerFailure`
/// and Firestore buffers writes made while offline as a hanging `Future`
/// rather than a rejection, so there is no failure signal to react to.
class OfflineAwareAction {
  const OfflineAwareAction(this._connectivity, this._enqueueOfflineAction);

  final ConnectivityCubit _connectivity;
  final EnqueueOfflineAction _enqueueOfflineAction;

  /// Runs [online] if connectivity is available, otherwise queues the
  /// action described by [type]/[payload]/[dedupKey] for later replay.
  ///
  /// Returns `null` when the action was queued (offline) — callers should
  /// treat that as its own outcome (e.g. emit a "queued" effect) rather
  /// than treating it as success or failure. Returns [online]'s result
  /// unchanged when connectivity was available.
  Future<Either<Failure, T>?> runOrQueue<T>({
    required Future<Either<Failure, T>> Function() online,
    required OfflineActionType type,
    required Map<String, dynamic> payload,
    required String dedupKey,
  }) async {
    if (_connectivity.isOffline) {
      await _enqueueOfflineAction(type: type, payload: payload, dedupKey: dedupKey);
      return null;
    }
    return online();
  }
}
