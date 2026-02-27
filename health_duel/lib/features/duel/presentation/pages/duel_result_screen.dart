import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/router/routes.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel Result Screen — Sports-energy dark aesthetic
///
/// Visual layout:
/// - Result header: gradient container (green win / red loss / amber tie)
///   + trophy/defeat emoji + Victory! / Defeat / Tie! text
/// - Step comparison: two stat cards side-by-side (winner glows green)
/// - Details row: start date, end date, duration
/// - CTA: Challenge Again (filled) + Back to Duels (outlined)
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
    if (!duel.isCompleted) return _buildNotCompleted(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duel Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _onShare(context),
            tooltip: 'Share Result',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResultHeader(duel: duel, currentUserId: currentUserId),
            const SizedBox(height: AppSpacing.md),
            _StepComparison(duel: duel, currentUserId: currentUserId),
            const SizedBox(height: AppSpacing.md),
            _DetailsCard(duel: duel),
            const SizedBox(height: AppSpacing.lg),
            _ActionButtons(currentUserId: currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildNotCompleted(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Duel Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Duel Still Active', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Results will be available once the 24-hour window completes.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}

// ─── Result Header ────────────────────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  final Duel duel;
  final String currentUserId;

  const _ResultHeader({required this.duel, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return switch (duel.result) {
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
    final color = isWinner ? context.appColors.success : context.appColors.opponent;
    final gradientColors = isWinner
        ? [const Color(0xFF0A2B1F), const Color(0xFF0C2030)]
        : [const Color(0xFF2B0F0A), const Color(0xFF200D12)];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            isWinner ? '🏆' : '💪',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isWinner ? 'Victory!' : 'Defeat',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.fullBorder,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              isWinner
                  ? 'Won by ${_compact(margin)} steps'
                  : 'Lost by ${_compact(margin)} steps',
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTieHeader(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.appColors.warning;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1F0A), Color(0xFF201708)],
        ),
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('🤝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text(
            "It's a Tie!",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Both walked the same number of steps',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _compact(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

// ─── Step Comparison ──────────────────────────────────────────────────────────

class _StepComparison extends StatelessWidget {
  final Duel duel;
  final String currentUserId;

  const _StepComparison({required this.duel, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChallenger = duel.challengerId == currentUserId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps = isChallenger ? duel.challengedSteps : duel.challengerSteps;
    final opponentId = isChallenger ? duel.challengedId : duel.challengerId;
    final iWon = duel.currentLeader == currentUserId;
    final oppWon = duel.currentLeader == opponentId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Final Steps', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StepCard(
                label: 'You',
                emoji: '🏃',
                steps: mySteps.value,
                color: Theme.of(context).colorScheme.primary,
                isWinner: iWon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'VS',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.appColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: _StepCard(
                label: 'Opponent',
                emoji: '👤',
                steps: opponentSteps.value,
                color: context.appColors.opponent,
                isWinner: oppWon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Step Card ────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String label;
  final String emoji;
  final int steps;
  final Color color;
  final bool isWinner;

  const _StepCard({
    required this.label,
    required this.emoji,
    required this.steps,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isWinner ? color : context.appColors.divider;
    final stepsText =
        steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k' : '$steps';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isWinner
            ? color.withValues(alpha: 0.08)
            : context.appColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: borderColor.withValues(alpha: isWinner ? 0.4 : 1),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isWinner) ...[
            Icon(Icons.emoji_events_rounded, color: context.appColors.gold, size: 20),
            const SizedBox(height: 4),
          ],
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stepsText,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'steps',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

// ─── Details Card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final Duel duel;

  const _DetailsCard({required this.duel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duel Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _detailRow(context, 'Started', _formatDateTime(duel.startTime)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow(context, 'Ended', _formatDateTime(duel.endTime)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow(context, 'Duration', '24 hours'),
          const SizedBox(height: AppSpacing.sm),
          _detailRow(
            context,
            'Status',
            duel.status.toString().split('.').last.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final String currentUserId;

  const _ActionButtons({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => context.pushReplacement(AppRoutes.createDuel, extra: currentUserId),
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Challenge Again'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to Duels'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
