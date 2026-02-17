import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel Result Screen - Display final competition results
///
/// Features:
/// - Winner/Loser/Tie display
/// - Final step counts
/// - Margin of victory
/// - Share button
/// - Celebratory animations
///
/// Displays different UI based on [DuelResult]:
/// - [WinnerResult] - Shows winner with trophy
/// - [TieResult] - Shows tie with balance icon
class DuelResultScreen extends StatelessWidget {
  final Duel duel;
  final String currentUserId;

  const DuelResultScreen({
    required this.duel,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!duel.isCompleted) {
      return _buildNotCompletedView(context);
    }

    final result = duel.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duel Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResult(context),
            tooltip: 'Share Result',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result header (winner/tie)
            _buildResultHeader(context, result),

            const SizedBox(height: AppSpacing.xl),

            // Final step counts
            _buildStepComparison(context),

            const SizedBox(height: AppSpacing.lg),

            // Result details card
            _buildResultDetails(context, result),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotCompletedView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duel Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Duel Still Active',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This duel is still ongoing. Results will be available once the 24-hour window completes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, DuelResult result) {
    return switch (result) {
      WinnerResult(:final winnerId, :final margin) => _buildWinnerHeader(
          context,
          isWinner: winnerId == currentUserId,
          margin: margin,
        ),
      TieResult() => _buildTieHeader(context),
    };
  }

  Widget _buildWinnerHeader(
    BuildContext context, {
    required bool isWinner,
    required int margin,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isWinner
              ? [Colors.green.shade400, Colors.green.shade700]
              : [Colors.red.shade400, Colors.red.shade700],
        ),
        borderRadius: AppRadius.xlBorder,
      ),
      child: Column(
        children: [
          Icon(
            isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isWinner ? 'Victory!' : 'Defeat',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isWinner
                ? 'You won by $margin steps!'
                : 'You lost by $margin steps',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTieHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.orange.shade700],
        ),
        borderRadius: AppRadius.xlBorder,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.balance,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "It's a Tie!",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Both participants walked the same number of steps',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepComparison(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isChallenger = duel.challengerId == currentUserId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps =
        isChallenger ? duel.challengedSteps : duel.challengerSteps;
    final opponentId =
        isChallenger ? duel.challengedId : duel.challengerId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Final Step Counts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // You
                _buildStepCount(
                  context,
                  label: 'You',
                  steps: mySteps.value,
                  color: colorScheme.primary,
                  isWinner: duel.currentLeader == currentUserId,
                ),

                // VS
                Icon(
                  Icons.compare_arrows,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),

                // Opponent
                _buildStepCount(
                  context,
                  label: 'Opponent',
                  steps: opponentSteps.value,
                  color: colorScheme.secondary,
                  isWinner: duel.currentLeader == opponentId,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCount(
    BuildContext context, {
    required String label,
    required int steps,
    required Color color,
    bool isWinner = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isWinner ? context.appColors.warning : color.withValues(alpha: 0.3),
              width: isWinner ? 3 : 2,
            ),
          ),
          child: Column(
            children: [
              if (isWinner)
                Icon(
                  Icons.emoji_events,
                  color: context.appColors.warning,
                  size: 24,
                ),
              Text(
                steps.toString(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'steps',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultDetails(BuildContext context, DuelResult result) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duel Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Started',
              _formatDateTime(duel.startTime),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              context,
              'Ended',
              _formatDateTime(duel.endTime),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              context,
              'Duration',
              '24 hours',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              context,
              'Status',
              duel.status.toString().split('.').last.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            // Navigate to create new duel
            // context.push('/duel/create');
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.replay),
          label: const Text('Challenge Again'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Duels'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }

  void _shareResult(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
