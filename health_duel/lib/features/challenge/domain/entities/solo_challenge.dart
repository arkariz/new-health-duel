import 'package:equatable/equatable.dart';
import 'package:health_duel/features/challenge/domain/value_objects/challenge_status.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Solo Challenge Entity — Aggregate Root
///
/// A 24-hour personal target. The MVP-plan "solo spine": what one person
/// can do on day one, before a duel even exists. Reuses the same 24-hour
/// window semantics as a duel, single-writer only — no concurrency, no
/// transaction, no multi-party rules.
class SoloChallenge extends Equatable {
  const SoloChallenge({
    required this.id,
    required this.userId,
    required this.metric,
    required this.target,
    required this.currentValue,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String userId;
  final DuelMetric metric;
  final int target;
  final int currentValue;
  final DateTime startTime;
  final DateTime endTime;
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isActive => status == ChallengeStatus.active && !isExpired;

  bool get isExpired {
    final now = DateTime.now();
    return status == ChallengeStatus.active && now.isAfter(endTime);
  }

  /// Past its 24h window but Firestore still says `active` — the client
  /// must finalize it, same as [Duel.needsCompletion].
  bool get needsCompletion =>
      status == ChallengeStatus.active && DateTime.now().isAfter(endTime);

  bool get metTarget => currentValue >= target;

  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    final remaining = endTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progressPercentage {
    if (target <= 0) return 0;
    return (currentValue / target).clamp(0.0, 1.0);
  }

  double get timeElapsedPercentage {
    if (!isActive) return 1;
    final totalDuration = endTime.difference(startTime);
    final elapsed = DateTime.now().difference(startTime);
    final percentage = elapsed.inMilliseconds / totalDuration.inMilliseconds;
    return percentage.clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        metric,
        target,
        currentValue,
        startTime,
        endTime,
        status,
        createdAt,
        completedAt,
      ];

  @override
  String toString() => 'SoloChallenge('
      'id: $id, user: $userId, status: $status, '
      '$currentValue/$target ${metric.unit})';
}
