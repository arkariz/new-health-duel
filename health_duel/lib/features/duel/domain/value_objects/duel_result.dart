import 'package:equatable/equatable.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';

/// Duel Result Value Object
///
/// Sealed class representing the outcome of a completed duel.
/// Can be either a winner/loser result or a tie.
///
/// Use pattern matching (switch expression) to handle both cases:
/// ```dart
/// final message = switch (result) {
///   WinnerResult(:final winnerId) => 'Winner: $winnerId',
///   TieResult() => 'It\'s a tie!',
/// };
/// ```
sealed class DuelResult extends Equatable {
  const DuelResult();

  /// Factory: Create winner/loser result
  const factory DuelResult.winner({
    required String winnerId,
    required String loserId,
    required StepCount winnerSteps,
    required StepCount loserSteps,
  }) = WinnerResult;

  /// Factory: Create tie result
  const factory DuelResult.tie({
    required String challengerId,
    required String challengedId,
    required StepCount steps,
  }) = TieResult;
}

/// Winner/Loser Result
///
/// Represents a duel where one participant won.
final class WinnerResult extends DuelResult {
  final String winnerId;
  final String loserId;
  final StepCount winnerSteps;
  final StepCount loserSteps;

  const WinnerResult({
    required this.winnerId,
    required this.loserId,
    required this.winnerSteps,
    required this.loserSteps,
  });

  /// Get margin of victory (step difference)
  int get margin => winnerSteps.value - loserSteps.value;

  @override
  List<Object> get props => [winnerId, loserId, winnerSteps, loserSteps];
}

/// Tie Result
///
/// Represents a duel where both participants had identical step counts.
final class TieResult extends DuelResult {
  final String challengerId;
  final String challengedId;
  final StepCount steps;

  const TieResult({
    required this.challengerId,
    required this.challengedId,
    required this.steps,
  });

  @override
  List<Object> get props => [challengerId, challengedId, steps];
}
