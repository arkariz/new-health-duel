import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/presentation/bloc/bloc.dart';

/// Step Counter View - Displays today's step count
///
/// Shows:
/// - Large step count number
/// - Progress ring (visual indicator)
/// - Source device info
/// - Manual entry badge (if applicable)
/// - Pull-to-refresh support
class StepCounterView extends StatelessWidget {
  const StepCounterView({
    required this.stepCount,
    this.isRefreshing = false,
    this.dailyGoal = 10000,
    super.key,
  });

  final StepCount stepCount;
  final bool isRefreshing;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (stepCount.value / dailyGoal).clamp(0.0, 1.0);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HealthBloc>().add(const HealthRefreshRequested());
        // Wait for refresh to complete
        await context.read<HealthBloc>().stream.firstWhere((state) => !state.isRefreshing);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: AppSpacing.xl,
        ),
        child: ConstrainedContent(
          maxWidth: 400,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step Counter Ring
              _StepCounterRing(
                stepCount: stepCount.value,
                progress: progress,
                dailyGoal: dailyGoal,
                isRefreshing: isRefreshing,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Goal Progress Text
              Text(
                '${(progress * 100).toInt()}% of daily goal',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Goal indicator
              _GoalIndicator(
                current: stepCount.value,
                goal: dailyGoal,
                isAchieved: stepCount.value >= dailyGoal,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Manual entry badge
              if (stepCount.hasManualEntries) ...[
                _ManualEntryBadge(),
                const SizedBox(height: AppSpacing.md),
              ],

              // Source device info
              if (stepCount.sourceDevice != null) ...[
                _SourceDeviceInfo(device: stepCount.sourceDevice!),
              ],

              // Last updated time
              const SizedBox(height: AppSpacing.sm),
              LiveTimeAgoText(
                stepCount.endTime,
                prefix: 'Updated ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

/// Step Counter Ring Widget
class _StepCounterRing extends StatelessWidget {
  const _StepCounterRing({
    required this.stepCount,
    required this.progress,
    required this.dailyGoal,
    this.isRefreshing = false,
  });

  final int stepCount;
  final double progress;
  final int dailyGoal;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = context.responsiveValue(phone: 200.0, tablet: 250.0, desktop: 280.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0 ? theme.colorScheme.primary : theme.colorScheme.secondary,
              ),
            ),
          ),

          // Refreshing indicator
          if (isRefreshing)
            const CircularProgressIndicator()
          else
            // Step count display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_walk,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  stepCount.compact,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'steps',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Goal Indicator
class _GoalIndicator extends StatelessWidget {
  const _GoalIndicator({
    required this.current,
    required this.goal,
    required this.isAchieved,
  });

  final int current;
  final int goal;
  final bool isAchieved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isAchieved
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.lgBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAchieved ? Icons.emoji_events : Icons.flag_outlined,
            size: 20,
            color: isAchieved
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isAchieved ? 'Goal achieved! 🎉' : 'Goal: ${goal.withCommas} steps',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isAchieved
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withAlpha((255 * 0.8).round()),
              fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Manual Entry Badge - Transparency for cheating detection
class _ManualEntryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note,
            size: 16,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Includes manual entries',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Source Device Info
class _SourceDeviceInfo extends StatelessWidget {
  const _SourceDeviceInfo({required this.device});

  final String device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.watch,
          size: 14,
          color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          device,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
          ),
        ),
      ],
    );
  }
}
