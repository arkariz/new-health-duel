import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';

/// Active Duel Screen — Sports-energy dark aesthetic
///
/// Visual layout:
/// - Arena card: dark gradient + green glow border + LIVE badge
/// - Two-column player layout with gradient avatars
/// - Split battle bar (green ← | → orange)
/// - Prominent countdown (tabular Syne font)
/// - 3-chip stats row (steps, lead, opponent)
/// - Motivational banner (green/orange/amber based on position)
///
/// BLoC wiring unchanged from original:
/// - EffectListener at root
/// - BlocBuilder for loading/error/loaded states
/// - Nested BlocBuilder (buildWhen: currentTime) for countdown
class ActiveDuelScreen extends StatefulWidget {
  final String duelId;
  final String currentUserId;

  const ActiveDuelScreen({
    required this.duelId,
    required this.currentUserId,
    super.key,
  });

  @override
  State<ActiveDuelScreen> createState() => _ActiveDuelScreenState();
}

class _ActiveDuelScreenState extends State<ActiveDuelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DuelBloc>().add(DuelLoadRequested(widget.duelId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<DuelBloc, DuelState>(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Duel'),
          actions: [
            BlocBuilder<DuelBloc, DuelState>(
              buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
              builder: (context, state) {
                if (state is DuelLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => context
                        .read<DuelBloc>()
                        .add(DuelManualRefreshRequested(widget.duelId)),
                    tooltip: 'Sync health data',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<DuelBloc, DuelState>(
          buildWhen: (prev, curr) =>
              prev.runtimeType != curr.runtimeType ||
              (prev is DuelLoading &&
                  curr is DuelLoading &&
                  prev.message != curr.message),
          builder: (context, state) {
            if (state is DuelLoading) return _buildLoading(context, state.message);
            if (state is DuelError) return _buildError(context, state.message);
            if (state is DuelLoaded) return _buildDuelView(context, state);
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // ─── Loading ─────────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context, String? message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            message ?? 'Loading duel...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error ───────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text('Failed to Load Duel', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loaded ──────────────────────────────────────────────────────────────────

  Widget _buildDuelView(BuildContext context, DuelLoaded state) {
    final duel = state.duel;
    final isChallenger = duel.challengerId == widget.currentUserId;
    final mySteps = isChallenger ? duel.challengerSteps : duel.challengedSteps;
    final opponentSteps = isChallenger ? duel.challengedSteps : duel.challengerSteps;
    final total = mySteps.value + opponentSteps.value;
    final myBattle = total > 0 ? mySteps.value / total : 0.5;
    final oppBattle = total > 0 ? opponentSteps.value / total : 0.5;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Arena Card ─────────────────────────────────────────────────────
          _ArenaCard(
            duel: duel,
            mySteps: mySteps.value,
            opponentSteps: opponentSteps.value,
            myBattle: myBattle,
            oppBattle: oppBattle,
            duelId: widget.duelId,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Countdown ──────────────────────────────────────────────────────
          BlocBuilder<DuelBloc, DuelState>(
            buildWhen: (prev, curr) {
              if (prev is! DuelLoaded || curr is! DuelLoaded) return true;
              return prev.currentTime != curr.currentTime;
            },
            builder: (context, state) {
              if (state is! DuelLoaded) return const SizedBox.shrink();
              return _CountdownCard(remaining: state.duel.remainingTime);
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Stats Chips ────────────────────────────────────────────────────
          _StatsRow(
            duel: duel,
            mySteps: mySteps.value,
            opponentSteps: opponentSteps.value,
            currentUserId: widget.currentUserId,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Motivational Banner ────────────────────────────────────────────
          _MotivationalBanner(
            duel: duel,
            currentUserId: widget.currentUserId,
          ),
        ],
      ),
    );
  }
}

// ─── Arena Card ──────────────────────────────────────────────────────────────

class _ArenaCard extends StatelessWidget {
  final Duel duel;
  final int mySteps;
  final int opponentSteps;
  final double myBattle;
  final double oppBattle;
  final String duelId;

  const _ArenaCard({
    required this.duel,
    required this.mySteps,
    required this.opponentSteps,
    required this.myBattle,
    required this.oppBattle,
    required this.duelId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final opponent = context.appColors.opponent;

    return Container(
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
                    _PlayerTile(
                      emoji: '🏃',
                      name: 'You',
                      steps: mySteps,
                      color: primary,
                      isGreen: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'VS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: context.appColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _PlayerTile(
                      emoji: '👤',
                      name: 'Opponent',
                      steps: opponentSteps,
                      color: opponent,
                      isGreen: false,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Battle bar split
                _BattleBar(
                  myBattle: myBattle,
                  oppBattle: oppBattle,
                  primary: primary,
                  opponent: opponent,
                ),

                const SizedBox(height: AppSpacing.md),

                // Duel info row
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: context.appColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ends ${_formatTime(duel.endTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(duel.timeElapsedPercentage * 100).toStringAsFixed(0)}% elapsed',
                      style: theme.textTheme.bodySmall?.copyWith(
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
                border: Border.all(color: primary.withValues(alpha: 0.3)),
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
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Player Tile ─────────────────────────────────────────────────────────────

class _PlayerTile extends StatelessWidget {
  final String emoji;
  final String name;
  final int steps;
  final Color color;
  final bool isGreen;

  const _PlayerTile({
    required this.emoji,
    required this.name,
    required this.steps,
    required this.color,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepsText =
        steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k steps' : '$steps steps';

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
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
                  stepsText,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Battle Bar ──────────────────────────────────────────────────────────────

class _BattleBar extends StatelessWidget {
  final double myBattle;
  final double oppBattle;
  final Color primary;
  final Color opponent;

  const _BattleBar({
    required this.myBattle,
    required this.oppBattle,
    required this.primary,
    required this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left — YOUR progress (fills left → right)
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
            child: Stack(
              children: [
                Container(height: 8, color: context.appColors.divider),
                FractionallySizedBox(
                  widthFactor: myBattle.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
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
          width: 2,
          height: 18,
          color: context.appColors.divider,
        ),

        // Right — OPPONENT progress (fills right → left)
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
            child: Stack(
              children: [
                Container(height: 8, color: context.appColors.divider),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: oppBattle.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
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
    );
  }
}

// ─── Countdown Card ───────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  final Duration remaining;

  const _CountdownCard({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    final isLow = remaining.inHours < 1;
    final color = isLow ? context.appColors.warning : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        children: [
          Text(
            isLow ? '⚡ HURRY UP!' : 'TIME REMAINING',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Duel duel;
  final int mySteps;
  final int opponentSteps;
  final String currentUserId;

  const _StatsRow({
    required this.duel,
    required this.mySteps,
    required this.opponentSteps,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final diff = duel.stepDifference;
    final isWinning = duel.isUserWinning(currentUserId);
    final leadColor = isWinning == true
        ? context.appColors.success
        : isWinning == false
            ? context.appColors.opponent
            : context.appColors.warning;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.directions_walk_rounded,
            label: 'Your Steps',
            value: _compact(mySteps),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            icon: Icons.trending_up_rounded,
            label: 'Lead',
            value: diff > 0 ? '+${_compact(diff)}' : _compact(diff),
            color: leadColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            icon: Icons.flag_rounded,
            label: 'Opp Steps',
            value: _compact(opponentSteps),
            color: context.appColors.opponent,
          ),
        ),
      ],
    );
  }

  String _compact(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

// ─── Motivational Banner ──────────────────────────────────────────────────────

class _MotivationalBanner extends StatelessWidget {
  final Duel duel;
  final String currentUserId;

  const _MotivationalBanner({
    required this.duel,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leader = duel.currentLeader;
    final isWinning = duel.isUserWinning(currentUserId);
    final diff = _compact(duel.stepDifference);

    final (message, icon, color) = leader == null
        ? (
            "It's a tie! Push harder to take the lead!",
            Icons.balance_rounded,
            context.appColors.warning,
          )
        : isWinning == true
            ? (
                'You\'re in the lead! Keep it up!',
                Icons.emoji_events_rounded,
                context.appColors.success,
              )
            : (
                'Behind by $diff steps — time to catch up!',
                Icons.directions_run_rounded,
                context.appColors.opponent,
              );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _compact(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
