import 'package:flutter/widgets.dart';

/// Border Radius Design Tokens
///
/// Defines consistent border radius values across the app.
/// Ensures visual harmony with unified corner rounding.
///
/// Usage:
/// ```dart
/// borderRadius: BorderRadius.circular(AppRadius.lg),
/// shape: RoundedRectangleBorder(
///   borderRadius: AppRadius.lgBorder,
/// ),
/// ```
///
/// See ADR-005 for design token strategy.
abstract final class AppRadius {
  AppRadius._();

  // ============================================================
  // Raw Values (double)
  // ============================================================

  /// Small radius (4px)
  ///
  /// Use for: subtle rounding, skeleton shapes, small chips
  static const double sm = 4;

  /// Medium radius (8px)
  ///
  /// Use for: buttons, inputs, small cards, tags
  static const double md = 8;

  /// Large radius (12px)
  ///
  /// Use for: cards, dialogs, sheets, containers
  static const double lg = 12;

  /// Extra large radius (16px)
  ///
  /// Use for: modals, large cards, featured content
  static const double xl = 16;

  /// Extra extra large radius (20px)
  ///
  /// Use for: pills, prominent buttons, hero cards
  static const double xxl = 20;

  /// Full radius (999px)
  ///
  /// Use for: circular shapes, pills, avatars, FAB
  static const double full = 999;

  // ============================================================
  // BorderRadius Convenience Getters
  // ============================================================

  /// Small border radius
  static BorderRadius get smBorder => BorderRadius.circular(sm);

  /// Medium border radius
  static BorderRadius get mdBorder => BorderRadius.circular(md);

  /// Large border radius
  static BorderRadius get lgBorder => BorderRadius.circular(lg);

  /// Extra large border radius
  static BorderRadius get xlBorder => BorderRadius.circular(xl);

  /// Extra extra large border radius
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);

  /// Full/circular border radius
  static BorderRadius get fullBorder => BorderRadius.circular(full);
}
