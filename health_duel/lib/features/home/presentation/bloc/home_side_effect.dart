part of 'home_bloc.dart';

extension HomeSideEffect on HomeBloc {
  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Navigate to login page after sign out or unauthenticated state
  NavigateGoEffect get _effectNavigateToLogin => NavigateGoEffect(route: AppRoutes.login);

  /// Navigate to health page
  NavigatePushEffect get _effectNavigateToHealth => NavigatePushEffect(route: AppRoutes.health);

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generic error snackbar
  ShowSnackBarEffect _effectError(String message) =>
      ShowSnackBarEffect(message: message, severity: FeedbackSeverity.error);

  /// Refresh failed snackbar (warning severity)
  ShowSnackBarEffect _effectRefreshError(String message) =>
      ShowSnackBarEffect(message: 'Failed to refresh: $message', severity: FeedbackSeverity.warning);
}
