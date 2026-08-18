import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/widgets/duel_arena_widgets.dart';

/// Share Card Widget — the shareable duel-result image
///
/// Fixed logical size (600×315, a 40:21 ratio matching the PRD's recommended
/// 1200×630 social-share dimensions). Captured off-screen via
/// `RenderRepaintBoundary.toImage(pixelRatio: 2.0)` by the result screen —
/// this widget itself is a plain, self-contained visual with no capture
/// logic of its own.
class ShareCardWidget extends StatelessWidget {

  const ShareCardWidget({
    required this.duel,
    required this.currentUserId,
    super.key,
  });
  final Duel duel;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = duel.result;

    final (gradientColors, accent, headline, winnerId, loserId) = switch (result) {
      WinnerResult(:final winnerId, :final loserId) => (
          [const Color(0xFF0A2B1F), const Color(0xFF0C2030)],
          context.appColors.success,
          'Duel complete!',
          winnerId,
          loserId,
        ),
      TieResult() => (
          [const Color(0xFF2B1F0A), const Color(0xFF201708)],
          context.appColors.warning,
          "It's a tie!",
          null,
          null,
        ),
    };

    return SizedBox(
      width: 600,
      height: 315,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '🏆',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'HEALTH DUEL',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: context.appColors.gold,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '24-Hour Step Duel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              headline,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            _ParticipantRow(
              duel: duel,
              winnerId: winnerId,
              loserId: loserId,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateRange(duel.startTime, duel.endTime),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Challenge me on Health Duel!',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.appColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    String fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }
}

/// Both participants, side by side — reuses [DuelPlayerTile] for the avatar
/// circle + name + steps, same visual language as the rest of the app.
class _ParticipantRow extends StatelessWidget {

  const _ParticipantRow({
    required this.duel,
    required this.winnerId,
    required this.loserId,
  });
  final Duel duel;
  final String? winnerId;
  final String? loserId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTile(context, duel.challengerId, duel.challengerName, duel.challengerValue, isMe: true),
        const SizedBox(width: AppSpacing.md),
        _buildTile(context, duel.challengedId, duel.challengedName, duel.challengedValue, isMe: false),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    String participantId,
    String name,
    StepCount steps, {
    required bool isMe,
  }) {
    final isWinner = participantId == winnerId;
    final isLoser = participantId == loserId;
    final color = isMe ? Theme.of(context).colorScheme.primary : context.appColors.opponent;

    final Widget avatarChild;
    if (isWinner) {
      avatarChild = const Text('🏆', style: TextStyle(fontSize: 18));
    } else if (isLoser) {
      avatarChild = const Text('🙇', style: TextStyle(fontSize: 18));
    } else {
      avatarChild = Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
      );
    }

    return DuelPlayerTile(
      avatarChild: avatarChild,
      isMe: isMe,
      name: name,
      steps: steps.value,
      color: color,
    );
  }
}
