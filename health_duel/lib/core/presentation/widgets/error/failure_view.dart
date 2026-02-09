import 'package:flutter/material.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/theme/theme.dart';

import 'failure_display_style.dart';

/// Widget to display a [Failure] with appropriate styling and retry action
///
/// Maps [Failure] types to icons, colors, and user-friendly messages.
/// Follows ADR-002 by providing user-friendly error handling.
///
/// Example:
/// ```dart
/// FailureView(
///   failure: NetworkFailure(message: 'No internet'),
///   onRetry: () => bloc.add(RetryEvent()),
/// )
/// ```
class FailureView extends StatelessWidget {
  const FailureView({required this.failure, this.onRetry, this.compact = false, super.key});

  /// The failure to display
  final Failure failure;

  /// Callback for retry action (if null, no retry button shown)
  final VoidCallback? onRetry;

  /// Use compact/inline mode (default: full screen mode)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return FailureInlineView(failure: failure, onRetry: onRetry);
    }

    return FailureFullScreenView(failure: failure, onRetry: onRetry);
  }
}

/// Full-screen failure view with large icon, title, message, and retry button
///
/// Use for empty states when an operation fails completely.
class FailureFullScreenView extends StatelessWidget {
  const FailureFullScreenView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final style = failure.displayStyle;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(style.icon, size: 80, color: style.color.withAlpha((255 * 0.7).round())),
            const SizedBox(height: AppSpacing.lg),
            Text(
              style.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
            ],
            if (failure.errorCode != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error code: ${failure.errorCode}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline/compact failure view for use within lists or cards
///
/// Use when showing errors alongside other content.
class FailureInlineView extends StatelessWidget {
  const FailureInlineView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final style = failure.displayStyle;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: style.color.withAlpha((255 * 0.1).round()),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: style.color.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        children: [
          Icon(style.icon, color: style.color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(style.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  failure.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh), tooltip: 'Retry'),
          ],
        ],
      ),
    );
  }
}
