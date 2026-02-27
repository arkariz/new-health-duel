import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel Card — Sports-energy dark aesthetic
///
/// Displays duel summary in list views.
///
/// Variants (driven by [duel.status]):
/// - **Active**: dark gradient arena card + LIVE badge + mini battle bar
/// - **Pending**: invitation card + accept / decline buttons (opponent only)
/// - **Completed**: result card + W/L badge
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
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;

  const _ActiveDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final opponent = context.appColors.opponent;

    final isChallenger = duel.challengerId == currentUserId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps = isChallenger ? duel.challengedSteps : duel.challengerSteps;
    final total = mySteps.value + opponentSteps.value;
    final myBattle = total > 0 ? mySteps.value / total : 0.5;
    final oppBattle = total > 0 ? opponentSteps.value / total : 0.5;
    final opponentId = isChallenger ? duel.challengedId : duel.challengerId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1F18), Color(0xFF0D1A23)],
          ),
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: primary.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Players row
                  Row(
                    children: [
                      _MiniPlayerTile(
                        initials: 'Me',
                        name: 'You',
                        steps: mySteps.value,
                        color: primary,
                        isGreen: true,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text(
                          'VS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.appColors.gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _MiniPlayerTile(
                        initials: opponentId.substring(0, 1).toUpperCase(),
                        name: 'Opponent',
                        steps: opponentSteps.value,
                        color: opponent,
                        isGreen: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Mini battle bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              Container(height: 5, color: context.appColors.divider),
                              FractionallySizedBox(
                                widthFactor: myBattle.clamp(0.0, 1.0),
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, const Color(0xFF00C87A)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: context.appColors.divider,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              Container(height: 5, color: context.appColors.divider),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FractionallySizedBox(
                                  widthFactor: oppBattle.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [const Color(0xFFCC4410), opponent],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Time row
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 11,
                        color: context.appColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ends ${_formatTime(duel.endTime)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // LIVE badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Pending Duel Card ────────────────────────────────────────────────────────

class _PendingDuelCard extends StatelessWidget {
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _PendingDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });

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

            // Accept / Decline buttons (opponent only)
            if (!isChallenger && (onAccept != null || onDecline != null)) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (onDecline != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: const Text('Decline'),
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
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;

  const _HistoryDuelCard({
    required this.duel,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChallenger = duel.challengerId == currentUserId;
    final opponentId = isChallenger ? duel.challengedId : duel.challengerId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps = isChallenger ? duel.challengedSteps : duel.challengerSteps;
    final iWon = duel.currentLeader == currentUserId;

    final resultColor = duel.status == DuelStatus.completed
        ? (iWon ? context.appColors.success : context.appColors.opponent)
        : context.appColors.divider;
    final resultLabel = duel.status == DuelStatus.completed
        ? (iWon ? 'WIN' : 'LOSS')
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
                  iWon ? '🏆' : '💪',
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
                    'vs ${opponentId.substring(0, 1).toUpperCase()}${opponentId.substring(1, opponentId.length > 6 ? 6 : opponentId.length)}',
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

// ─── Mini Player Tile ─────────────────────────────────────────────────────────

class _MiniPlayerTile extends StatelessWidget {
  final String initials;
  final String name;
  final int steps;
  final Color color;
  final bool isGreen;

  const _MiniPlayerTile({
    required this.initials,
    required this.name,
    required this.steps,
    required this.color,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepsText = steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k' : '$steps';

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isGreen
                    ? [const Color(0xFF00E5A0), const Color(0xFF00A872)]
                    : [const Color(0xFFFF6B35), const Color(0xFFCC4410)],
              ),
            ),
            child: Center(
              child: Text(
                initials.length > 2 ? initials.substring(0, 2) : initials,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isGreen ? const Color(0xFF060A0E) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$stepsText steps',
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
