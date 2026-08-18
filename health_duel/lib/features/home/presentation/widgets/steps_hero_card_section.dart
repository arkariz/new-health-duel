import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/health/presentation/bloc/health_bloc.dart';
import 'package:health_duel/features/health/presentation/bloc/health_state.dart';

/// Home hero card — reflects the user's actual active [SoloChallenge]
/// (real target, real progress) instead of a fixed made-up goal. With no
/// active challenge, it prompts to start one instead of showing 0%
/// against a number that doesn't mean anything yet.
class StepsHeroCardSection extends StatelessWidget {
  const StepsHeroCardSection({
    required this.onTap,
    this.activeChallenge,
    super.key,
  });

  final VoidCallback onTap;
  final SoloChallenge? activeChallenge;

  @override
  Widget build(BuildContext context) {
    final challenge = activeChallenge;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.xxlBorder,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                border: Border.all(color: context.appColors.divider),
              ),
              child: challenge == null
                  ? _NoChallengePrompt(primary: primary)
                  : _ActiveChallengeSummary(challenge: challenge, primary: primary),
            ),
            // Ambient glow top-right (radial gradient, no sharp edge)
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withValues(alpha: 0.28),
                      primary.withValues(alpha: 0.18),
                      primary.withValues(alpha: 0.09),
                      primary.withValues(alpha: 0.03),
                      primary.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.3, 0.55, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// No active challenge — still shows today's raw step count (live, via
/// [HealthBloc]) but frames it as a prompt rather than fake progress.
class _NoChallengePrompt extends StatelessWidget {
  const _NoChallengePrompt({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<HealthBloc, HealthState, int>(
      selector: (state) => state.todaySteps?.value ?? 0,
      builder: (context, steps) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S STEPS",
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: steps.withCommas,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' steps',
                  style: theme.textTheme.titleMedium?.copyWith(color: primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.flag_outlined, size: 18, color: primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'No active challenge — tap to set one',
                style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveChallengeSummary extends StatelessWidget {
  const _ActiveChallengeSummary({required this.challenge, required this.primary});
  final SoloChallenge challenge;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = challenge.progressPercentage;
    final remaining = challenge.remainingTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TODAY'S CHALLENGE",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: challenge.currentValue.withCommas,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              TextSpan(
                text: ' / ${challenge.target.withCommas} ${challenge.metric.unit}',
                style: theme.textTheme.titleMedium?.copyWith(color: primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${remaining.inHours}h ${remaining.inMinutes % 60}m left',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final fillWidth = constraints.maxWidth * progress;
            return SizedBox(
              height: 10,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.appColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    left: 0,
                    width: fillWidth,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primary, const Color(0xFF00FFBB)]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: fillWidth - 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
