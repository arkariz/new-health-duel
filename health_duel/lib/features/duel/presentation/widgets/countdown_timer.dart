import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Countdown Timer Widget - Displays remaining time in HH:MM:SS format
///
/// Features:
/// - Real-time countdown display
/// - Warning color when < 1 hour remaining
/// - Large readable format
class CountdownTimer extends StatelessWidget {
  final Duration remaining;

  const CountdownTimer({
    required this.remaining,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    final isLowTime = remaining.inHours < 1;
    final color = isLowTime ? context.appColors.warning : colorScheme.onSurface;

    return Column(
      children: [
        Text(
          'Time Remaining',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLowTime)
              Icon(
                Icons.warning_amber_rounded,
                color: color,
                size: 32,
              ),
            if (isLowTime) const SizedBox(width: AppSpacing.sm),
            Text(
              _formatTime(hours, minutes, seconds),
              style: theme.textTheme.displayMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isLowTime)
          Text(
            'Hurry! Less than 1 hour left',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _formatTime(int hours, int minutes, int seconds) {
    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
