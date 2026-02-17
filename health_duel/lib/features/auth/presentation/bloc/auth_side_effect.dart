part of 'auth_bloc.dart';

extension AuthSideEffect on AuthBloc {
  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Navigate to home page after successful authentication
  NavigateGoEffect get _effectNavigateToHome => NavigateGoEffect(route: AppRoutes.home);

  /// Navigate to login page after sign out
  NavigateGoEffect get _effectNavigateToLogin => NavigateGoEffect(route: AppRoutes.login);

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generic authentication error snackbar
  ShowSnackBarEffect _effectAuthError(String message) => ShowSnackBarEffect(message: message, severity: FeedbackSeverity.error);

  /// Account created successfully snackbar
  ShowSnackBarEffect get _effectAccountCreated => ShowSnackBarEffect(
    message: 'Account created successfully!',
    severity: FeedbackSeverity.success,
  );
}
