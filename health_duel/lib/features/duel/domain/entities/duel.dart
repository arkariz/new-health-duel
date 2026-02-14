import 'package:equatable/equatable.dart';
import 'package:health_duel/features/duel/domain/value_objects/value_objects.dart';

/// Duel Entity - Aggregate Root
///
/// Rich domain model representing a 24-hour step count competition.
/// Contains all business logic for duel lifecycle and rules.
///
/// **Lifecycle:**
/// 1. Created (pending) - Challenge sent
/// 2. Accepted (active) - Both users participating
/// 3. Completed - 24-hour window ended
///
/// **Immutable:** All properties final, use copyWith for updates.
class Duel extends Equatable {
  final String id;
  final String challengerId;
  final String challengedId;
  final StepCount challengerSteps;
  final StepCount challengedSteps;
  final DateTime startTime;
  final DateTime endTime;
  final DuelStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const Duel({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.challengerSteps,
    required this.challengedSteps,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // BUSINESS LOGIC METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if duel is currently active
  ///
  /// Active means:
  /// - Status is `active`
  /// - 24-hour window has not expired
  bool get isActive => status == DuelStatus.active && !isExpired;

  /// Check if duel is pending acceptance
  ///
  /// Pending means:
  /// - Status is `pending`
  /// - Invitation has not expired (24 hours)
  bool get isPending => status == DuelStatus.pending && !isPendingExpired;

  /// Check if duel has completed
  ///
  /// Completed means:
  /// - Status is `completed`, OR
  /// - Active duel has expired
  bool get isCompleted => status == DuelStatus.completed || isExpired;

  /// Check if 24-hour competition window has expired
  ///
  /// Only applies to active duels.
  bool get isExpired {
    final now = DateTime.now();
    return status == DuelStatus.active && now.isAfter(endTime);
  }

  /// Check if pending invitation has expired (24 hours)
  ///
  /// Pending invitations expire if not accepted within 24 hours.
  bool get isPendingExpired {
    final now = DateTime.now();
    final expirationTime = createdAt.add(const Duration(hours: 24));
    return status == DuelStatus.pending && now.isAfter(expirationTime);
  }

  /// Get remaining time in the duel competition
  ///
  /// Returns [Duration.zero] if duel is not active or has expired.
  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    final now = DateTime.now();
    final remaining = endTime.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get remaining time for pending acceptance
  ///
  /// Returns [Duration.zero] if not pending or already expired.
  Duration get pendingTimeRemaining {
    if (!isPending) return Duration.zero;
    final now = DateTime.now();
    final expirationTime = createdAt.add(const Duration(hours: 24));
    final remaining = expirationTime.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get percentage of time elapsed (0.0 - 1.0)
  ///
  /// Used for progress bars and UI visualization.
  /// Returns 1.0 if duel is not active.
  double get timeElapsedPercentage {
    if (!isActive) return 1.0;
    final totalDuration = endTime.difference(startTime);
    final elapsed = DateTime.now().difference(startTime);
    final percentage = elapsed.inMilliseconds / totalDuration.inMilliseconds;
    return percentage.clamp(0.0, 1.0);
  }

  /// Determine the current leader
  ///
  /// Returns user ID of participant with more steps.
  /// Returns `null` if tie (equal step counts).
  String? get currentLeader {
    if (challengerSteps == challengedSteps) return null; // Tie
    return challengerSteps > challengedSteps ? challengerId : challengedId;
  }

  /// Get winner at duel completion
  ///
  /// Throws [StateError] if duel is not completed.
  ///
  /// Returns [DuelResult] which can be:
  /// - [WinnerResult] - One participant won
  /// - [TieResult] - Both participants tied
  DuelResult get result {
    if (!isCompleted) {
      throw StateError('Cannot get result of non-completed duel');
    }

    // Check for tie
    if (challengerSteps == challengedSteps) {
      return DuelResult.tie(
        challengerId: challengerId,
        challengedId: challengedId,
        steps: challengerSteps,
      );
    }

    // Determine winner and loser
    final winnerId = challengerSteps > challengedSteps ? challengerId : challengedId;
    final loserId = winnerId == challengerId ? challengedId : challengerId;
    final winnerSteps = winnerId == challengerId ? challengerSteps : challengedSteps;
    final loserSteps = winnerId == challengerId ? challengedSteps : challengerSteps;

    return DuelResult.winner(
      winnerId: winnerId,
      loserId: loserId,
      winnerSteps: winnerSteps,
      loserSteps: loserSteps,
    );
  }

  /// Check if user is a participant in this duel
  ///
  /// Returns `true` if [userId] is either challenger or challenged.
  bool isParticipant(String userId) {
    return userId == challengerId || userId == challengedId;
  }

  /// Get opponent ID for given user
  ///
  /// Throws [ArgumentError] if user is not a participant.
  String getOpponentId(String userId) {
    if (!isParticipant(userId)) {
      throw ArgumentError('User $userId is not a participant in this duel');
    }
    return userId == challengerId ? challengedId : challengerId;
  }

  /// Get step count for specific user
  ///
  /// Throws [ArgumentError] if user is not a participant.
  StepCount getStepsForUser(String userId) {
    if (userId == challengerId) return challengerSteps;
    if (userId == challengedId) return challengedSteps;
    throw ArgumentError('User $userId is not a participant in this duel');
  }

  /// Calculate absolute step difference between participants
  ///
  /// Returns positive integer representing margin.
  int get stepDifference {
    return (challengerSteps.value - challengedSteps.value).abs();
  }

  /// Check if duel is expiring soon (less than 1 hour remaining)
  ///
  /// Useful for UI warnings.
  bool get isExpiringSoon {
    return isActive && remainingTime.inHours < 1;
  }

  /// Check if current user is winning
  ///
  /// Returns `null` if tie or user is not participant.
  bool? isUserWinning(String userId) {
    if (!isParticipant(userId)) return null;
    final leader = currentLeader;
    if (leader == null) return null; // Tie
    return leader == userId;
  }

  @override
  List<Object?> get props => [
    id,
    challengerId,
    challengedId,
    challengerSteps,
    challengedSteps,
    startTime,
    endTime,
    status,
    createdAt,
    acceptedAt,
    completedAt,
  ];

  @override
  String toString() => 'Duel('
  'id: $id, '
  'challenger: $challengerId, '
  'challenged: $challengedId, '
  'status: $status, '
  'steps: ${challengerSteps.value} vs ${challengedSteps.value}'
  ')';
}
