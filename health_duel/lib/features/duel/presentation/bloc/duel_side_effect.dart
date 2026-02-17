part of 'duel_bloc.dart';

/// Duel Side Effects - Helper methods for creating effects
extension DuelSideEffect on DuelBloc {
  // ════════════════════════════════════════════
  // NOTIFICATION EFFECTS
  // ════════════════════════════════════════════

  /// Lead changed notification
  ShowSnackBarEffect _effectLeadChanged(Duel duel) {
    final leader = duel.currentLeader;

    // Get leader name from denormalized data
    // (In full implementation, this would come from UserModel)
    final leaderName = leader == duel.challengerId
      ? 'Challenger' // TODO: Replace with actual user name when available
      : 'Challenged'; // TODO: Replace with actual user name when available

    return ShowSnackBarEffect(
      message: '$leaderName is winning by ${duel.stepDifference} steps!',
      severity: FeedbackSeverity.info,
    );
  }

  /// Duel completed notification
  ShowSnackBarEffect? _effectDuelCompleted(DuelResult? result) {
    if (result == null) return null;

    final message = switch (result) {
      WinnerResult(:final winnerSteps) => 'Duel completed! Winner: ${winnerSteps.value} steps',
      TieResult(:final steps) => 'Duel completed! Tie at ${steps.value} steps',
    };

    return ShowSnackBarEffect(
      message: message,
      severity: FeedbackSeverity.success,
    );
  }
}
