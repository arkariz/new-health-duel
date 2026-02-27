import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/home/home.dart';

class ActiveDuelsSection extends StatelessWidget {
  const ActiveDuelsSection({
    super.key,
    required this.onTapSeeAll,
    required this.onTapDuelCard,
  });

  final VoidCallback onTapSeeAll;
  final VoidCallback onTapDuelCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _renderHeader(theme, context, primary),
        const SizedBox(height: AppSpacing.sm),

        // Live Duel Card — tappable
        GestureDetector(
          onTap: onTapDuelCard,
          child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E1F18), Color(0xFF0D1A23)],
            ),
            borderRadius: AppRadius.xlBorder,
            border: Border.all(
              color: const Color(0xFF00E5A0).withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.md,
                  children: [
                    // Players row
                    _renderPlayerRow(primary, theme, context),
                    // Duel bar — split green/orange
                    _renderDuelBar(context, primary),
                    // Time & score information
                    _renderLowerCardInformation(context, theme),
                  ],
                ),
              ),
              // LIVE badge — absolute top-right
              _renderLiveBadge(primary, theme),
            ],
          ),
        ),
        ),
      ],
    );
  }

  Widget _renderHeader(ThemeData theme, BuildContext context, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Active Duels', style: theme.textTheme.titleLarge), // Syne
        TextButton(
          onPressed: onTapSeeAll,
          child: Text(
            'See all',
            style: theme.textTheme.labelMedium?.copyWith(
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  Row _renderPlayerRow(Color primary, ThemeData theme, BuildContext context) {
    return Row(
      children: [
        _DuelPlayerTile(
          emoji: '🏃',
          isGreen: true,
          name: 'You',
          steps: HomeDummy.mySteps,
          primary: primary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
          ),
          child: Text(
            'VS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.appColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _DuelPlayerTile(
          emoji: '👩',
          isGreen: false,
          name: HomeDummy.opponentName,
          steps: HomeDummy.opponentSteps,
          primary: context.appColors.opponent,
        ),
      ],
    );
  }

  Widget _renderDuelBar(BuildContext context, Color primary) {
    return Row(
      children: [
        // Left bar — YOUR progress (fills left-to-right)
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: context.appColors.divider,
                ),
                FractionallySizedBox(
                  widthFactor: HomeDummy.myBattleProgress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          const Color(0xFF00C87A),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Center divider
        Container(
          width: 2,
          height: 18,
          color: context.appColors.divider,
        ),
        // Right bar — OPPONENT progress (fills right-to-left)
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: context.appColors.divider,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor:
                        HomeDummy.opponentBattleProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFCC4410),
                            context.appColors.opponent,
                          ],
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
    );
  }

  Widget _renderLowerCardInformation(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 12,
          color: context.appColors.gold,
        ),
        const SizedBox(width: 4),
        Text(
          '${HomeDummy.timeRemaining} remaining',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'You\'re winning by ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: '1,332 steps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.appColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderLiveBadge(Color primary, ThemeData theme) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.smBorder,
          border: Border.all(
            color: primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          'LIVE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Player tile for the active duel card — avatar circle + name + steps
class _DuelPlayerTile extends StatelessWidget {
  const _DuelPlayerTile({
    required this.emoji,
    required this.isGreen,
    required this.name,
    required this.steps,
    required this.primary,
  });

  final String emoji;
  final bool isGreen;
  final String name;
  final int steps;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 38,
            height: 38,
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
              child: Text(emoji, style: const TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${steps.compact} steps',
                  style: theme.textTheme.bodySmall?.copyWith(color: primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}