import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:health_duel/features/duel/presentation/widgets/countdown_timer.dart';
import 'package:health_duel/features/duel/presentation/widgets/step_progress_bar.dart';
import 'package:health_duel/features/duel/presentation/widgets/sync_indicator.dart';

/// Active Duel Screen - Real-time duel monitoring
///
/// Features:
/// - Real-time Firestore updates
/// - Countdown timer (HH:MM:SS)
/// - Step progress bars (both participants)
/// - Lead indicator (who's winning)
/// - Last sync timestamp
/// - Manual refresh button
///
/// Uses [DuelBloc] with 3 real-time subscriptions:
/// 1. Firestore listener - Duel updates
/// 2. Health sync timer - Periodic (5 min)
/// 3. Countdown timer - UI updates (1 sec)
///
/// BlocProvider is provided by router, not by this screen.
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
    // Trigger initial load after frame is built
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
            // Manual refresh button in app bar
            BlocBuilder<DuelBloc, DuelState>(
              buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
              builder: (context, state) {
                if (state is DuelLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<DuelBloc>().add(DuelManualRefreshRequested(widget.duelId)),
                    tooltip: 'Sync health data now',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<DuelBloc, DuelState>(
          buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType || (prev is DuelLoading && curr is DuelLoading && prev.message != curr.message),
          builder: (context, state) {
            // Loading state
            if (state is DuelLoading) {
              return _buildLoadingView(context, state.message);
            }

            // Error state
            if (state is DuelError) {
              return _buildErrorView(context, state.message);
            }

            // Loaded state - Real-time duel monitoring
            if (state is DuelLoaded) {
              return _buildDuelView(context, state);
            }

            // Initial state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            message ?? 'Loading duel...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error Loading Duel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuelView(BuildContext context, DuelLoaded state) {
    final duel = state.duel;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Countdown Timer
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocBuilder<DuelBloc, DuelState>(
                // Rebuild only on time updates (currentTime changes)
                buildWhen: (prev, curr) {
                  if (prev is! DuelLoaded || curr is! DuelLoaded) return true;
                  return prev.currentTime != curr.currentTime;
                },
                builder: (context, state) {
                  if (state is DuelLoaded) {
                    final remaining = state.duel.remainingTime;
                    return CountdownTimer(remaining: remaining);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Step Progress Bars
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  StepProgressBar(
                    duel: duel,
                    currentUserId: widget.currentUserId,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Sync Indicator
          BlocBuilder<DuelBloc, DuelState>(
            buildWhen: (prev, curr) {
              if (prev is! DuelLoaded || curr is! DuelLoaded) return true;
              return prev.lastSyncTime != curr.lastSyncTime;
            },
            builder: (context, state) {
              if (state is DuelLoaded) {
                return SyncIndicator(
                  lastSyncTime: state.lastSyncTime,
                  isSyncing: false, // TODO: Add syncing state to bloc if needed
                  onRefresh: () => context.read<DuelBloc>().add(DuelManualRefreshRequested(widget.duelId)),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Duel Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duel Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Status',
                    duel.status.toString().split('.').last.toUpperCase(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    context,
                    'Started',
                    _formatDateTime(duel.startTime),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    context,
                    'Ends',
                    _formatDateTime(duel.endTime),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    context,
                    'Time Elapsed',
                    '${(duel.timeElapsedPercentage * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Motivational message based on lead
          _buildMotivationalMessage(context, duel),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(BuildContext context, Duel duel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isWinning = duel.isUserWinning(widget.currentUserId);
    final leader = duel.currentLeader;

    String message;
    IconData icon;
    Color color;

    if (leader == null) {
      // Tie
      message = "It's a tie! Keep pushing to take the lead!";
      icon = Icons.balance;
      color = context.appColors.warning;
    } else if (isWinning == true) {
      // Winning
      message = "You're in the lead! Keep it up!";
      icon = Icons.emoji_events;
      color = context.appColors.success;
    } else {
      // Losing
      final difference = duel.stepDifference;
      message = "You're behind by $difference steps. Time to catch up!";
      icon = Icons.directions_run;
      color = colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Future
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
