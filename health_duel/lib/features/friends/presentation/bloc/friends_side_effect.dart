part of 'friends_bloc.dart';

extension FriendsSideEffect on FriendsBloc {
  ShowSnackBarEffect _effectFriendAdded(String name) => ShowSnackBarEffect(
        message: '$name added as friend!',
        severity: FeedbackSeverity.success,
      );

  ShowSnackBarEffect _effectFriendRemoved() => ShowSnackBarEffect(
        message: 'Friend removed.',
        severity: FeedbackSeverity.info,
      );

  ShowSnackBarEffect _effectError(String message) => ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );
}
