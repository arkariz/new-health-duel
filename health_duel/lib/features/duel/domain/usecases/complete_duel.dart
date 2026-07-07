import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';

/// Complete Duel Use Case
///
/// Finalizes an expired active duel from the client side.
///
/// Thin delegation: all validation (duel exists, still active, past its
/// end time) happens inside the repository's Firestore transaction so the
/// check-and-write is atomic and race-safe between both participants.
class CompleteDuel {

  const CompleteDuel(this._repository);
  final DuelRepository _repository;

  /// Execute duel completion
  ///
  /// Writes status=completed, winnerId (null on tie), completedAt=endTime.
  /// Idempotent if the duel was already completed by the other participant.
  ///
  /// Returns completed [Duel] or [Failure].
  Future<Either<Failure, Duel>> call(String duelId) =>
      _repository.completeDuel(duelId);
}
