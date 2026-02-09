part of 'app_dialog.dart';

/// Compact dialog icon widget
///
/// Renders a [DialogIcon] with appropriate size and color.
/// Used in [AlertDialog.icon] or similar contexts.
class DialogIconWidget extends StatelessWidget {
  const DialogIconWidget({
    required this.icon,
    this.size = 32,
    super.key,
  });

  final DialogIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>() ?? AppColorsExtension.light;

    final (iconData, color) = switch (icon) {
      DialogIcon.info => (Icons.info_outline, theme.colorScheme.primary),
      DialogIcon.error => (Icons.error_outline, theme.colorScheme.error),
      DialogIcon.success => (Icons.check_circle_outline, appColors.success),
      DialogIcon.question => (Icons.help_outline, theme.colorScheme.secondary),
      DialogIcon.warning => (Icons.warning_amber, appColors.warning),
    };

    return Icon(iconData, size: size, color: color);
  }
}