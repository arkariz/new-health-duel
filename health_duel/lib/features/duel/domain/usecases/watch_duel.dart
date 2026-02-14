import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Watch Duel Use Case
///
/// Subscribe to real-time updates for a specific duel.
///
/// Returns stream that emits whenever duel data changes in Firestore.
class WatchDuel {
  final DuelRepository _repository;

  const WatchDuel(this._repository);

  /// Execute real-time subscription
  ///
  /// Returns stream of duel updates.
  /// Stream continues until cancelled.
  Stream<Either<Failure, Duel>> call(String duelId) {
    return _repository.watchDuel(duelId);
  }
}
