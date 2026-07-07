import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Expire Pending Duel Use Case
///
/// Finalizes a pending invitation that was never accepted within 24 hours.
///
/// Thin delegation: validation (duel exists, still pending, past its
/// 24-hour acceptance window) happens inside the repository's Firestore
/// transaction so the check-and-write is atomic and race-safe.
class ExpirePendingDuel {

  const ExpirePendingDuel(this._repository);
  final DuelRepository _repository;

  /// Execute pending duel expiration
  ///
  /// Writes status=expired. Idempotent if the duel was already
  /// accepted/declined/expired.
  ///
  /// Returns expired [Duel] or [Failure].
  Future<Either<Failure, Duel>> call(String duelId) =>
      _repository.expirePendingDuel(duelId);
}
