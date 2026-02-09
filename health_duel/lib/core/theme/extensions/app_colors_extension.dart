import 'package:flutter/material.dart';

/// Extended Color Tokens via ThemeExtension
///
/// Provides semantic colors that adapt to light/dark theme.
/// Access via `Theme.of(context).extension<AppColorsExtension>()`.
///
/// Usage:
/// ```dart
/// final colors = Theme.of(context).extension<AppColorsExtension>()!;
/// Container(color: colors.success);
/// ```
///
/// Or with the convenience extension:
/// ```dart
/// Container(color: context.appColors.success);
/// ```
///
/// See ADR-005 for design token strategy.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.info,
    required this.cardBackground,
    required this.subtleBackground,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Success color (green) - confirmations, completed states
  final Color success;

  /// Warning color (amber/yellow) - alerts, pending states
  final Color warning;

  /// Info color (blue) - informational messages
  final Color info;

  /// Card background - elevated surfaces
  final Color cardBackground;

  /// Subtle background - muted surfaces, skeleton base
  final Color subtleBackground;

  /// Divider color - separators, borders
  final Color divider;

  /// Shimmer base color
  final Color shimmerBase;

  /// Shimmer highlight color
  final Color shimmerHighlight;

  /// Light theme colors
  static const light = AppColorsExtension(
    success: Color(0xFF10B981), // Emerald 500
    warning: Color(0xFFF59E0B), // Amber 500
    info: Color(0xFF3B82F6), // Blue 500
    cardBackground: Color(0xFFFFFFFF),
    subtleBackground: Color(0xFFF3F4F6), // Gray 100
    divider: Color(0xFFE5E7EB), // Gray 200
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF9FAFB),
  );

  /// Dark theme colors
  static const dark = AppColorsExtension(
    success: Color(0xFF34D399), // Emerald 400
    warning: Color(0xFFFBBF24), // Amber 400
    info: Color(0xFF60A5FA), // Blue 400
    cardBackground: Color(0xFF1F2937), // Gray 800
    subtleBackground: Color(0xFF374151), // Gray 700
    divider: Color(0xFF4B5563), // Gray 600
    shimmerBase: Color(0xFF374151),
    shimmerHighlight: Color(0xFF4B5563),
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? cardBackground,
    Color? subtleBackground,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      cardBackground: cardBackground ?? this.cardBackground,
      subtleBackground: subtleBackground ?? this.subtleBackground,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      subtleBackground: Color.lerp(subtleBackground, other.subtleBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// Convenience extension for accessing AppColorsExtension
extension AppColorsContext on BuildContext {
  /// Access app colors from current theme
  ///
  /// Usage:
  /// ```dart
  /// Container(color: context.appColors.success);
  /// ```
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
  }
}
