part of 'health_bloc.dart';

extension HealthSideEffect on HealthBloc {
  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Creates fresh dialog effect each time (required for timestamp uniqueness)
  ShowDialogEffect get _effectUnavailableDialog => ShowDialogEffect.fullScreen(
    intentId: 'health_unavailable',
    title: 'Health Connect Required',
    message: 'Please install Google Health Connect from the Play Store to track your steps.',
    actions: const [DialogActionConfig(action: DialogAction.confirm, label: 'OK', isPrimary: true)],
  );

  /// Creates fresh dialog effect each time (required for timestamp uniqueness)
  ShowDialogEffect get _effectNotSupportedDialog => ShowDialogEffect(
    intentId: 'health_not_supported',
    title: 'Not Supported',
    message: "Your device doesn't support health data tracking.",
    icon: DialogIcon.info,
    isDismissible: true,
    actions: const [DialogActionConfig(action: DialogAction.confirm, label: 'OK', isPrimary: true)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Permission denied snackbar
  ShowSnackBarEffect get _effectPermissionDeniedSnackbar => ShowSnackBarEffect(
    message: 'Health permission denied. You can enable it in Settings.',
    severity: FeedbackSeverity.warning,
  );

  /// Failed to refresh steps snackbar
  ShowSnackBarEffect _effectRefreshFailedSnackbar(String message) => ShowSnackBarEffect(
    message: 'Failed to refresh steps: $message',
    severity: FeedbackSeverity.error,
  );

  /// Permissions revoked snackbar
  ShowSnackBarEffect get _effectPermissionsRevokedSnackbar => ShowSnackBarEffect(
    message: 'Health permissions revoked',
    severity: FeedbackSeverity.info,
  );

  /// Generic error snackbar
  ShowSnackBarEffect _effectErrorSnackbar(String message) => ShowSnackBarEffect(
    message: message,
    severity: FeedbackSeverity.error,
  );
}