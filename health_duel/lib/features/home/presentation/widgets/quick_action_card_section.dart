import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

class QuickActionCardSection extends StatelessWidget {
  const QuickActionCardSection({
    super.key,
    required this.onTapNewDuel,
    required this.onTapWeeklyStats,
  });

  final VoidCallback onTapNewDuel;
  final VoidCallback onTapWeeklyStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleLarge),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            _QuickActionCard(
              icon: '⚔️',
              label: 'New Duel',
              value: '6,847 today',
              onTap: onTapNewDuel,
            ),
            _QuickActionCard(
              icon: '📊',
              label: 'Weekly Stats',
              value: '+12% this week',
              onTap: onTapWeeklyStats,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: context.appColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            Text(
              icon,
              style: theme.textTheme.headlineMedium,
            ),
            Text(label, style: theme.textTheme.titleSmall),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
