part of 'duel_list_bloc.dart';

extension DuelListSideEffect on DuelListBloc {
  ShowSnackBarEffect _effectAcceptSuccess() => ShowSnackBarEffect(
        message: 'Duel accepted! The competition has started.',
        severity: FeedbackSeverity.success,
      );

  ShowSnackBarEffect _effectDeclineSuccess() => ShowSnackBarEffect(
        message: 'Duel invitation declined.',
        severity: FeedbackSeverity.info,
      );

  ShowSnackBarEffect _effectError(String message) => ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );
}
