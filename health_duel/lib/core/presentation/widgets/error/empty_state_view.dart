import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Empty state widget for lists with no data
///
/// Use this when a list or view has no content to display.
/// Provides a friendly message with optional action button.
///
/// Example:
/// ```dart
/// EmptyStateView(
///   title: 'No transactions yet',
///   subtitle: 'Add your first transaction to get started',
///   icon: Icons.receipt_long_outlined,
///   actionLabel: 'Add Transaction',
///   action: () => context.push('/add-transaction'),
/// )
/// ```
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({required this.title, this.subtitle, this.icon = Icons.inbox_outlined, this.action, this.actionLabel, super.key});

  /// Main title text
  final String title;

  /// Optional subtitle/description
  final String? subtitle;

  /// Icon to display (defaults to inbox icon)
  final IconData icon;

  /// Optional action callback
  final VoidCallback? action;

  /// Label for action button (required if action is provided)
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.onSurface.withAlpha((255 * 0.3).round())),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(onPressed: action, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
