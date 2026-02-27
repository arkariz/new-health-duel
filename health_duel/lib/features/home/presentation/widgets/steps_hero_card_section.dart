import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/home/home.dart';

class StepsHeroCardSection extends StatelessWidget {
  const StepsHeroCardSection({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  "TODAY'S STEPS",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Big number + unit — RichText
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: HomeDummy.todaySteps.withCommas,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: ' steps',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: HomeDummy.stepProgress.toPercentage(),
                        // text: '${(HomeDummy.stepProgress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: primary,
                        ),
                      ),
                      TextSpan(
                        text: ' of daily goal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Custom progress bar with glow dot
                LayoutBuilder(
                  builder: (context, constraints) {
                    const progress = HomeDummy.stepProgress; // 0.68
                    final fillWidth = constraints.maxWidth * progress;
                    return SizedBox(
                      height: 10,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Track
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
                          // Fill — gradient
                          Positioned(
                            top: 2,
                            left: 0,
                            width: fillWidth,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primary, const Color(0xFF00FFBB)],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          // Glow dot at end of fill
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
                const SizedBox(height: AppSpacing.xs),
                // Meta row
                Text(
                  'Goal: ${HomeDummy.stepGoal.withCommas}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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