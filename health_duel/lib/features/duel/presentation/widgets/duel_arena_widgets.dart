import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';

/// Split battle progress bar — green fills left-to-right, orange fills right-to-left.
///
/// Used at three sizes:
/// - `height: 8` (default) — ActiveDuelScreen arena card & home ActiveDuelsSection
/// - `height: 5` — compact DuelCard list item
///
/// When both step counts are 0, both bars render empty (0 width) instead of
/// showing a misleading 50/50 split.
class DuelBattleBar extends StatelessWidget {

  const DuelBattleBar({
    required this.mySteps,
    required this.opponentSteps,
    this.height = 8.0,
    super.key,
  });
  final int mySteps;
  final int opponentSteps;

  /// Bar thickness in logical pixels. Divider dimensions are derived automatically.
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = mySteps + opponentSteps;
    final myFraction = total > 0 ? (mySteps / total).clamp(0.0, 1.0) : 0.0;
    final oppFraction = total > 0 ? (opponentSteps / total).clamp(0.0, 1.0) : 0.0;

    final primary = Theme.of(context).colorScheme.primary;
    final opponent = context.appColors.opponent;
    final radius = Radius.circular(height / 2);

    // Divider scales with bar height
    final dividerWidth = height >= 7 ? 2.0 : 1.0;
    final dividerHeight = height >= 7 ? 18.0 : 12.0;

    return Row(
      children: [
        // Left bar — MY progress (fills left → right)
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
            child: Stack(
              children: [
                Container(height: height, color: context.appColors.divider),
                FractionallySizedBox(
                  widthFactor: myFraction,
                  child: Container(
                    height: height,
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

        // Center divider
        Container(
          width: dividerWidth,
          height: dividerHeight,
          color: context.appColors.divider,
        ),

        // Right bar — OPPONENT progress (fills right → left)
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(topRight: radius, bottomRight: radius),
            child: Stack(
              children: [
                Container(height: height, color: context.appColors.divider),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: oppFraction,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
    );
  }
}

/// Duel player tile — gradient avatar circle + name + step count.
///
/// Used at three sizes across the app:
/// - `avatarSize: 40` (default) — ActiveDuelScreen arena card
/// - `avatarSize: 38` — home ActiveDuelsSection preview card
/// - `avatarSize: 32`, `compact: true` — DuelCard compact list item
///
/// Pass any widget as [avatarChild]:
/// - Emoji: `Text('🏃', style: TextStyle(fontSize: 18))`
/// - Initials: `Text('Me', style: theme.textTheme.labelSmall?.copyWith(...))`
class DuelPlayerTile extends StatelessWidget {

  const DuelPlayerTile({
    required this.avatarChild,
    required this.isMe,
    required this.name,
    required this.steps,
    required this.color,
    this.avatarSize = 40.0,
    this.compact = false,
    super.key,
  });
  /// Content rendered inside the avatar circle (emoji or initials).
  final Widget avatarChild;

  /// `true` = green gradient (current user), `false` = orange gradient (opponent).
  final bool isMe;

  /// Diameter of the avatar circle in logical pixels.
  final double avatarSize;

  final String name;
  final int steps;

  /// Color applied to the steps sub-label.
  final Color color;

  /// When `true`, uses compact label text styles instead of title/body styles.
  /// Set to `true` for the DuelCard compact list variant.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final nameStyle = compact ? theme.textTheme.labelMedium : theme.textTheme.titleSmall;
    final stepsStyle = compact ? theme.textTheme.labelSmall : theme.textTheme.bodySmall;
    final stepsText =
        steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k steps' : '$steps steps';
    final gap = avatarSize >= 38 ? AppSpacing.sm : 6.0;

    return Expanded(
      child: Row(
        children: [
          // Gradient avatar circle
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isMe
                    ? [const Color(0xFF00E5A0), const Color(0xFF00A872)]
                    : [const Color(0xFFFF6B35), const Color(0xFFCC4410)],
              ),
            ),
            child: Center(child: avatarChild),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: nameStyle, overflow: TextOverflow.ellipsis),
                Text(stepsText, style: stepsStyle?.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full active-duel card — dark gradient shell with players row, battle bar,
/// LIVE badge, and a configurable footer row.
///
/// Used in three contexts:
/// - `ActiveDuelScreen` — full-size arena card (no margin, no tap)
/// - `DuelCard` list item — compact variant (`compact: true`, with margin)
/// - `ActiveDuelsSection` home preview — full-size with tap
///
/// The [footerTimeText] and optional [footerTrailingText]/[footerTrailingColor]
/// cover every bottom-row variant without requiring callers to build Widget trees.
class DuelActiveCard extends StatelessWidget {

  const DuelActiveCard({
    required this.duel,
    required this.currentUserId,
    required this.footerTimeText,
    this.onTap,
    this.compact = false,
    this.margin,
    this.footerTrailingText,
    this.footerTrailingColor,
    super.key,
  });
  final Duel duel;
  final String currentUserId;
  final VoidCallback? onTap;

  /// `true` → avatarSize 32, barHeight 5, initials in avatar (for list items).
  /// `false` (default) → avatarSize 40, barHeight 8, emoji in avatar.
  final bool compact;

  /// Optional outer margin, e.g. for list-item spacing.
  final EdgeInsets? margin;

  /// Left side of footer: time info (e.g. "Ends 14:30" or "3h 20m remaining").
  final String footerTimeText;

  /// Optional right side of footer (e.g. "72% elapsed" or lead status text).
  final String? footerTrailingText;

  /// Color for [footerTrailingText]. Defaults to [onSurfaceVariant] if omitted.
  final Color? footerTrailingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final opponent = context.appColors.opponent;

    final isChallenger = duel.challengerId == currentUserId;
    final mySteps = isChallenger ? duel.challengerValue.value : duel.challengedValue.value;
    final oppSteps = isChallenger ? duel.challengedValue.value : duel.challengerValue.value;
    final opponentName = isChallenger ? duel.challengedName : duel.challengerName;

    final avatarSize = compact ? 32.0 : 40.0;
    final barHeight = compact ? 5.0 : 8.0;

    // Avatar inner content — initials for compact, emoji for full-size
    final meAvatar = compact
        ? Text(
            'Me',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF060A0E),
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          )
        : const Text('🏃', style: TextStyle(fontSize: 18));

    final oppInitial = opponentName.isNotEmpty ? opponentName[0].toUpperCase() : '?';
    final oppAvatar = compact
        ? Text(
            oppInitial,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          )
        : const Text('👤', style: TextStyle(fontSize: 18));

    final Widget card = Container(
      margin: margin,
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
              spacing: compact ? AppSpacing.sm : AppSpacing.md,
              children: [
                // Players row
                Row(
                  children: [
                    DuelPlayerTile(
                      avatarChild: meAvatar,
                      isMe: true,
                      name: 'You',
                      steps: mySteps,
                      color: primary,
                      avatarSize: avatarSize,
                      compact: compact,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'VS',
                        style: (compact
                                ? theme.textTheme.labelSmall
                                : theme.textTheme.labelMedium)
                            ?.copyWith(
                          color: context.appColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    DuelPlayerTile(
                      avatarChild: oppAvatar,
                      isMe: false,
                      name: opponentName,
                      steps: oppSteps,
                      color: opponent,
                      avatarSize: avatarSize,
                      compact: compact,
                    ),
                  ],
                ),

                // Battle bar
                DuelBattleBar(
                  mySteps: mySteps,
                  opponentSteps: oppSteps,
                  height: barHeight,
                ),

                // Footer row
                _DuelCardFooter(
                  timeText: footerTimeText,
                  trailingText: footerTrailingText,
                  trailingColor: footerTrailingColor,
                  compact: compact,
                ),
              ],
            ),
          ),

          // LIVE badge
          Positioned(
            top: compact ? 10 : 12,
            right: compact ? 10 : 12,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 6.0 : AppSpacing.sm,
                vertical: compact ? 2.0 : 3.0,
              ),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.smBorder,
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'LIVE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  letterSpacing: compact ? 1.5 : 2.0,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 9.0 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class _DuelCardFooter extends StatelessWidget {

  const _DuelCardFooter({
    required this.timeText,
    required this.compact,
    this.trailingText,
    this.trailingColor,
  });
  final String timeText;
  final String? trailingText;
  final Color? trailingColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = compact ? theme.textTheme.labelSmall : theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: compact ? 11.0 : 12.0,
          color: context.appColors.gold,
        ),
        const SizedBox(width: 4),
        Text(timeText, style: textStyle?.copyWith(color: muted)),
        if (trailingText != null) ...[
          const Spacer(),
          Text(
            trailingText!,
            style: textStyle?.copyWith(
              color: trailingColor ?? muted,
              fontWeight: trailingColor != null ? FontWeight.w600 : null,
            ),
          ),
        ],
      ],
    );
  }
}
