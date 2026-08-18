import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/widgets/duel_arena_widgets.dart';

/// Duel Card — Sports-energy dark aesthetic
///
/// Displays duel summary in list views.
///
/// Variants (driven by [Duel.status]):
/// - **Active**: dark gradient arena card + LIVE badge + mini battle bar
/// - **Pending**: invitation card + accept / decline buttons (opponent only)
/// - **Completed**: result card + W/L badge
class DuelCard extends StatelessWidget {

  const DuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
    this.onAccept,
    this.onDecline,
    super.key,
  });
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return switch (duel.status) {
      DuelStatus.active => _ActiveDuelCard(
          duel: duel,
          currentUserId: currentUserId,
          onTap: onTap,
        ),
      DuelStatus.pending => _PendingDuelCard(
          duel: duel,
          currentUserId: currentUserId,
          onTap: onTap,
          onAccept: onAccept,
          onDecline: onDecline,
        ),
      _ => _HistoryDuelCard(
          duel: duel,
          currentUserId: currentUserId,
          onTap: onTap,
        ),
    };
  }
}

// ─── Active Duel Card ─────────────────────────────────────────────────────────

class _ActiveDuelCard extends StatelessWidget {

  const _ActiveDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
  });
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DuelActiveCard(
      duel: duel,
      currentUserId: currentUserId,
      onTap: onTap,
      compact: true,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      footerTimeText: 'Ends ${_formatTime(duel.endTime)}',
    );
  }

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Pending Duel Card ────────────────────────────────────────────────────────

class _PendingDuelCard extends StatelessWidget {

  const _PendingDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChallenger = duel.challengerId == currentUserId;
    final opponentId = isChallenger ? duel.challengedId : duel.challengerId;
    final warningColor = context.appColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: warningColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: warningColor.withValues(alpha: 0.1),
                    border: Border.all(color: warningColor.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      opponentId.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: warningColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChallenger ? 'Challenge sent' : 'Challenge received',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        isChallenger
                            ? 'Waiting for opponent to accept'
                            : 'Accept to start a 24h duel!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pending badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: warningColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(color: warningColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'PENDING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: warningColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),

            // Accept / Decline (received) or Cancel (sent) buttons
            if (onAccept != null || onDecline != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (onDecline != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: Text(isChallenger ? 'Cancel' : 'Decline'),
                      ),
                    ),
                  if (onDecline != null && onAccept != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (onAccept != null)
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
    );
  }
}

// ─── History Duel Card ────────────────────────────────────────────────────────

class _HistoryDuelCard extends StatelessWidget {

  const _HistoryDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
  });
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChallenger = duel.challengerId == currentUserId;
    final opponentName = isChallenger ? duel.challengedName : duel.challengerName;
    final mySteps = isChallenger ? duel.challengerValue : duel.challengedValue;
    final opponentSteps = isChallenger ? duel.challengedValue : duel.challengerValue;
    final isTie = duel.currentLeader == null;
    final iWon = !isTie && duel.currentLeader == currentUserId;

    final resultColor = duel.status == DuelStatus.completed
        ? (isTie
            ? context.appColors.warning
            : (iWon ? context.appColors.success : context.appColors.opponent))
        : context.appColors.divider;
    final resultLabel = duel.status == DuelStatus.completed
        ? (isTie ? 'TIE' : (iWon ? 'WIN' : 'LOSS'))
        : duel.status.toString().split('.').last.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: resultColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Result badge (left)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultColor.withValues(alpha: 0.1),
                border: Border.all(color: resultColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  isTie ? '🤝' : (iWon ? '🏆' : '🙇'),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Opponent + steps
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs $opponentName',
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_compact(mySteps.value)} vs ${_compact(opponentSteps.value)} steps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // W/L badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorder,
                border: Border.all(color: resultColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                resultLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: resultColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _compact(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}
