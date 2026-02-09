import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Type of message banner
enum MessageBannerType {
  /// Red background for critical errors
  error,

  /// Orange background for warnings
  warning,

  /// Blue background for informational messages
  info,

  /// Green background for success messages
  success,
}

/// Banner for showing messages at the top/bottom of screens
///
/// Use for temporary notifications that don't require a [Failure] object.
/// For displaying [Failure] types, use [FailureView] instead.
///
/// Example:
/// ```dart
/// MessageBanner(
///   message: 'Changes saved successfully',
///   type: MessageBannerType.success,
///   onDismiss: () => setState(() => showBanner = false),
/// )
/// ```
class MessageBanner extends StatelessWidget {
  const MessageBanner({required this.message, this.onDismiss, this.onRetry, this.type = MessageBannerType.info, super.key});

  /// Message to display in the banner
  final String message;

  /// Callback when dismiss button is pressed
  final VoidCallback? onDismiss;

  /// Callback when retry button is pressed (only shown for error/warning)
  final VoidCallback? onRetry;

  /// Type of banner (affects color scheme and icon)
  final MessageBannerType type;

  @override
  Widget build(BuildContext context) {
    final config = _getBannerStyle(type);

    return Material(
      color: config.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              Icon(config.icon, color: config.foregroundColor, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(message, style: TextStyle(color: config.foregroundColor))),
              if (onRetry != null && (type == MessageBannerType.error || type == MessageBannerType.warning))
                TextButton(onPressed: onRetry, child: Text('Retry', style: TextStyle(color: config.foregroundColor))),
              if (onDismiss != null)
                IconButton(onPressed: onDismiss, icon: Icon(Icons.close, color: config.foregroundColor), iconSize: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal styling configuration for banners
class _BannerStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _BannerStyle({required this.backgroundColor, required this.foregroundColor, required this.icon});
}

_BannerStyle _getBannerStyle(MessageBannerType type) {
  return switch (type) {
    MessageBannerType.error => const _BannerStyle(
      backgroundColor: Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      icon: Icons.error_outline,
    ),
    MessageBannerType.warning => const _BannerStyle(
      backgroundColor: Color(0xFFF57C00),
      foregroundColor: Colors.white,
      icon: Icons.warning_amber_rounded,
    ),
    MessageBannerType.info => const _BannerStyle(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      icon: Icons.info_outline,
    ),
    MessageBannerType.success => const _BannerStyle(
      backgroundColor: Color(0xFF388E3C),
      foregroundColor: Colors.white,
      icon: Icons.check_circle_outline,
    ),
  };
}
