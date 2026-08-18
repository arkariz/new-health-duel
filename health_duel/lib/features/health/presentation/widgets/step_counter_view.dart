import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/presentation/bloc/bloc.dart';

/// Step Counter View — raw Health Connect diagnostics.
///
/// Deliberately has no target/goal of its own: that's the Challenge
/// screen's job (`/challenge`, real target from an active
/// `SoloChallenge`). This view exists to answer "is my step data syncing,
/// and where's it coming from" — source device, manual-entry transparency,
/// last-updated time — not to duplicate a progress ring.
class StepCounterView extends StatelessWidget {
  const StepCounterView({
    required this.stepCount,
    this.isRefreshing = false,
    super.key,
  });

  final StepCount stepCount;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              _StepCountDisplay(stepCount: stepCount.value, isRefreshing: isRefreshing),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'from Health Connect',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
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

/// Plain step count display — a ring with no progress arc, since this
/// screen doesn't track a target.
class _StepCountDisplay extends StatelessWidget {
  const _StepCountDisplay({
    required this.stepCount,
    this.isRefreshing = false,
  });

  final int stepCount;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = context.responsiveValue<double>(phone: 200, tablet: 250, desktop: 280);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest, width: 12),
      ),
      child: Center(
        child: isRefreshing
            ? const CircularProgressIndicator()
            : Column(
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
                    'steps today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                ],
              ),
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
