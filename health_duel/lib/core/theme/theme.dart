/// Theme Barrel Export
///
/// Provides centralized access to theme configuration, tokens, and extensions.
///
/// Usage:
/// ```dart
/// import 'package:health_duel/core/theme/theme.dart';
///
/// // Access tokens
/// padding: EdgeInsets.all(AppSpacing.md),
/// borderRadius: BorderRadius.circular(AppRadius.lg),
/// duration: AppDurations.normal,
///
/// // Access theme colors
/// color: context.appColors.success,
///
/// // Access theme data
/// theme: AppTheme.lightTheme,
/// ```
///
/// See ADR-005 for design token strategy.
library;

export 'app_theme.dart';
export 'extensions/extensions.dart';
export 'tokens/tokens.dart';
