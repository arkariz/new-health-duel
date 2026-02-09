part of 'app_dialog.dart';

/// Fullscreen dialog content widget
///
/// A centered, user-friendly fullscreen dialog with:
/// - Optional icon with appropriate styling based on [DialogIcon]
/// - Title and message
/// - Primary/secondary action buttons
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (ctx) => Dialog.fullscreen(
///     child: FullscreenDialogContent(
///       icon: DialogIcon.warning,
///       title: 'Are you sure?',
///       message: 'This action cannot be undone.',
///       actions: [
///         DialogActionConfig(action: DialogAction.cancel),
///         DialogActionConfig(action: DialogAction.destructive, isPrimary: true),
///       ],
///     ),
///   ),
/// );
/// ```
class _FullscreenDialogContent extends StatelessWidget {
  const _FullscreenDialogContent({
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
  });

  /// Optional icon to display at the top
  final DialogIcon? icon;

  /// Dialog title
  final String title;

  /// Dialog message/description
  final String message;

  /// Action buttons to display
  final List<DialogActionConfig> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Icon
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(theme),
                  shape: BoxShape.circle,
                ),
                child: _buildLargeIcon(theme),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Actions
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actions
                  .map((config) => _buildActionButton(context, config))
                  .toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    final appColors = theme.extension<AppColorsExtension>() ?? AppColorsExtension.light;
    return switch (icon) {
      DialogIcon.error => theme.colorScheme.errorContainer,
      DialogIcon.success => appColors.success.withAlpha((255 * 0.15).round()),
      DialogIcon.warning => appColors.warning.withAlpha((255 * 0.15).round()),
      DialogIcon.info => theme.colorScheme.primaryContainer,
      DialogIcon.question => theme.colorScheme.secondaryContainer,
      null => theme.colorScheme.surfaceContainerHighest,
    };
  }

  Widget _buildLargeIcon(ThemeData theme) {
    final appColors = theme.extension<AppColorsExtension>() ?? AppColorsExtension.light;
    final (iconData, color) = switch (icon) {
      DialogIcon.error => (Icons.error_outline, theme.colorScheme.error),
      DialogIcon.success => (Icons.check_circle_outline, appColors.success),
      DialogIcon.warning => (Icons.warning_amber_rounded, appColors.warning),
      DialogIcon.info => (Icons.info_outline, theme.colorScheme.primary),
      DialogIcon.question => (Icons.help_outline, theme.colorScheme.secondary),
      null => (Icons.info_outline, theme.colorScheme.primary),
    };

    return Icon(iconData, size: 64, color: color);
  }

  Widget _buildActionButton(BuildContext context, DialogActionConfig config) {
    final theme = Theme.of(context);

    void handlePress() {
      // Call config's onPressed callback first (if any)
      config.onPressed?.call();
      // Then call widget-level callback or pop
      Navigator.of(context).pop(config.action);

    }

    if (config.isPrimary) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FilledButton(
          onPressed: handlePress,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: config.action == DialogAction.destructive
              ? theme.colorScheme.error
              : null,
          ),
          child: Text(config.effectiveLabel),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: OutlinedButton(
        onPressed: handlePress,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: config.action == DialogAction.destructive
            ? theme.colorScheme.error
            : null,
        ),
        child: Text(config.effectiveLabel),
      ),
    );
  }
}