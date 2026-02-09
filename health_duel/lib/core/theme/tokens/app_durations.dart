/// Animation Duration Design Tokens
///
/// Defines consistent animation timing across the app.
/// Based on Material Design motion guidelines.
///
/// Usage:
/// ```dart
/// duration: AppDurations.normal,
/// AnimatedContainer(duration: AppDurations.fast),
/// ```
///
/// See ADR-005 for design token strategy.
abstract final class AppDurations {
  AppDurations._();

  /// Instant duration (0ms)
  ///
  /// Use for: no animation, immediate state changes
  static const Duration zero = Duration.zero;

  /// Fast duration (150ms)
  ///
  /// Use for: micro-interactions, hover states, icon changes
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal duration (300ms)
  ///
  /// Use for: standard transitions, page elements, most animations
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow duration (500ms)
  ///
  /// Use for: emphasis animations, important state changes
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow duration (700ms)
  ///
  /// Use for: page transitions, dramatic effects
  static const Duration extraSlow = Duration(milliseconds: 700);

  // ============================================================
  // Raw Values (milliseconds) for custom Duration construction
  // ============================================================

  /// Fast in milliseconds
  static const int fastMs = 150;

  /// Normal in milliseconds
  static const int normalMs = 300;

  /// Slow in milliseconds
  static const int slowMs = 500;

  /// Extra slow in milliseconds
  static const int extraSlowMs = 700;
}
