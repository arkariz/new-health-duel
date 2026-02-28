part of 'create_duel_bloc.dart';

extension CreateDuelSideEffect on CreateDuelBloc {
  ShowSnackBarEffect _effectSuccess() => ShowSnackBarEffect(
        message: 'Challenge sent! Waiting for opponent to accept.',
        severity: FeedbackSeverity.success,
      );

  ShowSnackBarEffect _effectError(String message) => ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );
}
