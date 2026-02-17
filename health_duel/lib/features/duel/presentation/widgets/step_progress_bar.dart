import 'package:flutter/material.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Step Progress Bar - Visual comparison of step counts
///
/// Shows:
/// - Two horizontal progress bars (user vs opponent)
/// - Current step counts
/// - Lead indicator
/// - Percentage progress
class StepProgressBar extends StatelessWidget {
  final Duel duel;
  final String currentUserId;

  const StepProgressBar({
    required this.duel,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isChallenger = duel.challengerId == currentUserId;
    final mySteps =
        isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps =
        isChallenger ? duel.challengedSteps : duel.challengerSteps;

    final maxSteps = mySteps > opponentSteps ? mySteps.value : opponentSteps.value;
    final normalizedMax = maxSteps > 0 ? maxSteps : 10000; // Fallback

    final myProgress = mySteps.value / normalizedMax;
    final opponentProgress = opponentSteps.value / normalizedMax;

    final isLeading = duel.currentLeader == currentUserId;
    final opponentId =
        isChallenger ? duel.challengedId : duel.challengerId;

    return Column(
      children: [
        // You
        _buildProgressRow(
          context,
          label: 'You',
          steps: mySteps.value,
          progress: myProgress,
          color: colorScheme.primary,
          isLeading: isLeading,
        ),

        const SizedBox(height: 24),

        // Opponent
        _buildProgressRow(
          context,
          label: 'Opponent',
          steps: opponentSteps.value,
          progress: opponentProgress,
          color: colorScheme.secondary,
          isLeading: duel.currentLeader == opponentId,
        ),

        const SizedBox(height: 16),

        // Difference
        if (duel.stepDifference > 0) _buildDifference(context),
      ],
    );
  }

  Widget _buildProgressRow(
    BuildContext context, {
    required String label,
    required int steps,
    required double progress,
    required Color color,
    bool isLeading = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                if (isLeading)
                  Icon(
                    Icons.emoji_events,
                    size: 20,
                    color: Colors.amber,
                  ),
              ],
            ),
            Text(
              '$steps steps',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 24,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDifference(BuildContext context) {
    final theme = Theme.of(context);
    final difference = duel.stepDifference;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_run,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Difference: $difference steps',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
