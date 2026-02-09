import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/theme/theme.dart';

import 'connectivity_cubit.dart';
import 'connectivity_state.dart';

/// Widget that displays offline banner when device is offline
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: content),
///     ],
///   ),
/// )
/// ```
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({this.message = 'No internet connection', this.showRetry = false, this.onRetry, super.key});

  /// Message to display in the banner
  final String message;

  /// Whether to show retry button
  final bool showRetry;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        if (status != ConnectivityStatus.offline) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.grey.shade800,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 18),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  if (showRetry && onRetry != null)
                    TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated offline banner that slides in/out
///
/// Uses [AnimatedSwitcher] for smooth slide transition when
/// connectivity status changes.
class AnimatedOfflineBanner extends StatelessWidget {
  const AnimatedOfflineBanner({this.message = 'No internet connection', super.key});

  /// Message to display in the banner
  final String message;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)), child: child);
          },
          child: status == ConnectivityStatus.offline ? _OfflineBannerContent(key: const ValueKey('offline'), message: message) : const SizedBox.shrink(key: ValueKey('online')),
        );
      },
    );
  }
}

/// Internal widget for offline banner content
class _OfflineBannerContent extends StatelessWidget {
  const _OfflineBannerContent({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade800,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
