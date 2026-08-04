import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';

/// Replays a single [OfflineActionType] through its existing use case
/// (ADR-006) — never a direct repository/Firestore call, so domain
/// validation re-runs on replay and doubles as conflict detection.
abstract class OfflineActionExecutor {
  OfflineActionType get type;

  /// Replays [payload] through the underlying use case.
  ///
  /// A [ValidationFailure] result is treated by the processor as a conflict
  /// (drop + notify); any other failure is retried with backoff.
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload);

  /// User-facing message shown when [execute] conflicts, given the same
  /// [payload] that was queued.
  String conflictMessage(Map<String, dynamic> payload);
}
