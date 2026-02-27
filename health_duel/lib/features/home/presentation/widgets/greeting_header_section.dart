import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

class GreetingHeaderSection extends StatelessWidget {
  const GreetingHeaderSection({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                username,
                style: theme.textTheme.titleLarge, // Syne bold
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Notification button — 36x36, card background, divider border
        Container(
          width: AppSpacing.xl,
          height: AppSpacing.xl,
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: context.appColors.divider),
          ),
          child: const Center(
            child: Text('🔔')
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}