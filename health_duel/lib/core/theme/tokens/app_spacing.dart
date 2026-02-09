/// Spacing Design Tokens
///
/// Defines the spacing rhythm for consistent layouts.
/// Based on 4px base unit with semantic naming.
///
/// Usage:
/// ```dart
/// padding: EdgeInsets.all(AppSpacing.md),
/// SizedBox(height: AppSpacing.lg),
/// gap: AppSpacing.sm,
/// ```
///
/// See ADR-005 for design token strategy.
abstract final class AppSpacing {
  AppSpacing._();

  /// Extra small spacing (4px)
  ///
  /// Use for: tight spacing, dense lists, inline elements
  static const double xs = 4;

  /// Small spacing (8px)
  ///
  /// Use for: small gaps, compact layouts, icon padding
  static const double sm = 8;

  /// Medium spacing (16px)
  ///
  /// Use for: standard padding, form field gaps, card content
  static const double md = 16;

  /// Large spacing (24px)
  ///
  /// Use for: section spacing, card margins, group separation
  static const double lg = 24;

  /// Extra large spacing (32px)
  ///
  /// Use for: page margins, major section breaks
  static const double xl = 32;

  /// Extra extra large spacing (48px)
  ///
  /// Use for: hero sections, major visual breaks, page headers
  static const double xxl = 48;

  /// Extra extra extra large spacing (64px)
  ///
  /// Use for: splash screens, onboarding, dramatic spacing
  static const double xxxl = 64;
}
