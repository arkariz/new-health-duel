part of 'challenge_bloc.dart';

extension ChallengeSideEffect on SoloChallengeBloc {
  ShowSnackBarEffect _effectError(String message) => ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );

  ShowSnackBarEffect _effectChallengeCompleted(SoloChallenge challenge) {
    return ShowSnackBarEffect(
      message: challenge.metTarget
          ? 'Challenge complete! You hit ${challenge.currentValue} ${challenge.metric.unit}.'
          : 'Challenge over — ${challenge.currentValue}/${challenge.target} ${challenge.metric.unit}. Next one starts your streak fresh.',
      severity: challenge.metTarget ? FeedbackSeverity.success : FeedbackSeverity.info,
    );
  }
}
