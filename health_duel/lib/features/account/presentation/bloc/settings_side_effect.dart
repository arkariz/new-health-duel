part of 'settings_bloc.dart';

extension SettingsSideEffect on SettingsBloc {
  NavigateGoEffect get _effectNavigateToLogin => NavigateGoEffect(route: AppRoutes.login);

  ShowSnackBarEffect get _effectAccountDeleted => ShowSnackBarEffect(
        message: 'Your account has been deleted.',
      );

  ShowSnackBarEffect _effectError(String message) => ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );
}
