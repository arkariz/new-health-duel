import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';

/// Duel Repository Interface
///
/// Defines all operations for managing duels.
/// Implemented by data layer (Firestore).
abstract class DuelRepository {
  /// Create a new duel challenge
  ///
  /// Creates a pending duel between challenger and challenged user.
  /// Duel starts when challenged user accepts.
  ///
  /// Returns created [Duel] or [Failure].
  Future<Either<Failure, Duel>> createDuel({
    required String challengerId,
    required String challengedId,
  });

  /// Accept a pending duel
  ///
  /// Transitions duel from pending to active.
  /// Sets start/end timestamps (24-hour window).
  ///
  /// Returns updated [Duel] or [Failure].
  Future<Either<Failure, Duel>> acceptDuel(String duelId);

  /// Cancel/decline a pending duel
  ///
  /// Sets duel status to cancelled.
  /// Can only cancel pending duels.
  ///
  /// Returns [Failure] if operation fails.
  Future<Either<Failure, void>> cancelDuel(String duelId);

  /// Get duel by ID
  ///
  /// Returns [Duel] or [Failure] if not found.
  Future<Either<Failure, Duel>> getDuelById(String duelId);

  /// Get active duels for a user
  ///
  /// Returns list of duels where:
  /// - User is a participant
  /// - Status is `active`
  /// - Not expired
  ///
  /// Sorted by start time (most recent first).
  Future<Either<Failure, List<Duel>>> getActiveDuels(String userId);

  /// Get pending duel invitations for a user
  ///
  /// Returns list of duels where:
  /// - User is challenged (not challenger)
  /// - Status is `pending`
  /// - Not expired
  ///
  /// Sorted by creation time (newest first).
  Future<Either<Failure, List<Duel>>> getPendingDuels(String userId);

  /// Get duel history (completed duels) for a user
  ///
  /// Returns list of completed duels where user participated.
  /// Sorted by completion time (most recent first).
  Future<Either<Failure, List<Duel>>> getDuelHistory(String userId);

  /// Check if active duel exists between two users
  ///
  /// Returns [Duel] if active duel exists, `null` if not.
  /// Used to prevent duplicate active duels.
  Future<Either<Failure, Duel?>> getActiveDuelBetween(
    String userId1,
    String userId2,
  );

  /// Update step count for a participant
  ///
  /// Updates step count for specified user in the duel.
  /// Only works for active duels.
  ///
  /// Returns updated [Duel] or [Failure].
  Future<Either<Failure, Duel>> updateStepCount({
    required String duelId,
    required String userId,
    required StepCount steps,
  });

  /// Watch real-time duel updates
  ///
  /// Returns stream that emits whenever duel data changes in Firestore.
  /// Stream continues until cancelled.
  ///
  /// Use for active duel screen to show live step count updates.
  Stream<Either<Failure, Duel>> watchDuel(String duelId);

  /// Watch real-time active duels for user
  ///
  /// Returns stream that emits whenever user's active duels change.
  /// Useful for home screen duel list.
  Stream<Either<Failure, List<Duel>>> watchActiveDuels(String userId);
}
