import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel Card - Displays duel summary in list views
///
/// Shows:
/// - Opponent name and avatar
/// - Current status (pending/active/completed)
/// - Step counts for both participants
/// - Quick action buttons based on status
class DuelCard extends StatelessWidget {
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const DuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
    this.onAccept,
    this.onDecline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final isChallenger = duel.challengerId == currentUserId;
    final opponentId = isChallenger ? duel.challengedId : duel.challengerId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps = isChallenger ? duel.challengedSteps : duel.challengerSteps;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Name + Status badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      opponentId.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opponent: $opponentId',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildStatusBadge(context),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Step counts comparison
              if (duel.isActive || duel.isCompleted) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepCount(
                      context,
                      'You',
                      mySteps.value,
                      isLeading: duel.currentLeader == currentUserId,
                    ),
                    const Icon(Icons.trending_flat),
                    _buildStepCount(
                      context,
                      'Opponent',
                      opponentSteps.value,
                      isLeading: duel.currentLeader == opponentId,
                    ),
                  ],
                ),
              ],

              // Action buttons for pending duels
              if (duel.isPending && !isChallenger) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (text, color) = switch (duel.status) {
      DuelStatus.pending => ('Pending', context.appColors.warning),
      DuelStatus.active => ('Active', colorScheme.primary),
      DuelStatus.completed => ('Completed', context.appColors.success),
      DuelStatus.cancelled => ('Cancelled', Colors.grey),
      DuelStatus.expired => ('Expired', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepCount(
    BuildContext context,
    String label,
    int steps, {
    bool isLeading = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeading)
              Icon(
                Icons.emoji_events,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              steps.toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          'steps',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
