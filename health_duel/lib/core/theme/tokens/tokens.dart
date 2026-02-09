/// Design Tokens Barrel Export
///
/// Provides centralized access to all design tokens.
///
/// Usage:
/// ```dart
/// import 'package:health_duel/core/theme/tokens/tokens.dart';
///
/// padding: EdgeInsets.all(AppSpacing.md),
/// borderRadius: BorderRadius.circular(AppRadius.lg),
/// duration: AppDurations.normal,
/// ```
///
/// See ADR-005 for design token strategy.
library;

export 'app_durations.dart';
export 'app_radius.dart';
export 'app_spacing.dart';
