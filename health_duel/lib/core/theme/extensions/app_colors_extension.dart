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
    required this.opponent,
    required this.gold,
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

  /// Opponent color (orange) — duel opponent, competitor states, timer urgency
  final Color opponent;

  /// Gold color — VS badge, crown, trophy, achievements
  final Color gold;

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
    success: Color(0xFF00A87A),      // Brand Green (WCAG AA on white)
    warning: Color(0xFFF59E0B),      // Amber 500
    info: Color(0xFF0E89C4),         // Blue (accessible on white)
    opponent: Color(0xFFE85A24),     // Orange (accessible on white)
    gold: Color(0xFFD4A020),         // Gold (accessible on white)
    cardBackground: Color(0xFFFFFFFF),
    subtleBackground: Color(0xFFF3F4F6), // Gray 100
    divider: Color(0xFFE5E7EB), // Gray 200
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF9FAFB),
  );

  /// Dark theme colors (Mockup Design System — sports-energy palette)
  static const dark = AppColorsExtension(
    success: Color(0xFF00E5A0),      // Brand Green #00E5A0
    warning: Color(0xFFFBBF24),      // Amber 400
    info: Color(0xFF38B6FF),         // Blue #38B6FF
    opponent: Color(0xFFFF6B35),     // Orange #FF6B35
    gold: Color(0xFFFFC94A),         // Gold #FFC94A
    cardBackground: Color(0xFF141B22),   // --card
    subtleBackground: Color(0xFF0E1318), // --surface
    divider: Color(0xFF1E2A34),         // --border
    shimmerBase: Color(0xFF1E2A34),
    shimmerHighlight: Color(0xFF263544),
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? opponent,
    Color? gold,
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
      opponent: opponent ?? this.opponent,
      gold: gold ?? this.gold,
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
      opponent: Color.lerp(opponent, other.opponent, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
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
