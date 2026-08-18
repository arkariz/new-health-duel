import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_bloc.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_event.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_state.dart';

/// Solo Challenge screen — the "solo spine". One screen, three states:
/// no active challenge (set a target), an active challenge (live
/// progress), or a just-finished one (inline result, no separate route).
class SoloChallengeScreen extends StatefulWidget {
  const SoloChallengeScreen({super.key});

  @override
  State<SoloChallengeScreen> createState() => _SoloChallengeScreenState();
}

class _SoloChallengeScreenState extends State<SoloChallengeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SoloChallengeBloc>().add(const ChallengeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<SoloChallengeBloc, ChallengeState>(
      child: Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: BlocBuilder<SoloChallengeBloc, ChallengeState>(
          builder: (context, state) => switch (state) {
            ChallengeLoaded(:final challenge) when challenge == null =>
              const _SetTargetView(),
            ChallengeLoaded(:final challenge) when challenge!.status.isFinal =>
              _ChallengeResultView(challenge: challenge),
            ChallengeLoaded(:final challenge) => _ActiveChallengeView(
                challenge: challenge!,
                currentTime: state.currentTime,
                lastSyncTime: state.lastSyncTime,
              ),
            ChallengeError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<SoloChallengeBloc>().add(const ChallengeLoadRequested()),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _SetTargetView extends StatefulWidget {
  const _SetTargetView();

  @override
  State<_SetTargetView> createState() => _SetTargetViewState();
}

class _SetTargetViewState extends State<_SetTargetView> {
  static const _presets = [5000, 8000, 10000, 12000];
  int _selectedTarget = 8000;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<SoloChallengeBloc, ChallengeState, bool>(
      selector: (state) => state is ChallengeLoaded && state.isStarting,
      builder: (context, isStarting) => _buildContent(context, theme, isStarting),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isStarting) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text("Set today's challenge", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '24 hours, one target. Beat it to keep your streak alive.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: _presets.map((target) {
                final selected = target == _selectedTarget;
                return ChoiceChip(
                  label: Text('${target ~/ 1000}k steps'),
                  selected: selected,
                  onSelected: isStarting ? null : (_) => setState(() => _selectedTarget = target),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: isStarting
                  ? null
                  : () => context.read<SoloChallengeBloc>().add(ChallengeStartRequested(_selectedTarget)),
              child: isStarting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChallengeView extends StatelessWidget {
  const _ActiveChallengeView({
    required this.challenge,
    required this.currentTime,
    this.lastSyncTime,
  });

  final SoloChallenge challenge;
  final DateTime currentTime;
  final DateTime? lastSyncTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = challenge.remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SoloChallengeBloc>().add(ChallengeManualRefreshRequested(challenge.id));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '${challenge.currentValue}',
                  style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'of ${challenge.target} ${challenge.metric.unit}',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercentage,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${hours}h ${minutes}m remaining',
                  style: theme.textTheme.bodyMedium,
                ),
                if (lastSyncTime != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Synced ${_relativeTime(lastSyncTime!, currentTime)}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time, DateTime now) {
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _ChallengeResultView extends StatelessWidget {
  const _ChallengeResultView({required this.challenge});
  final SoloChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final met = challenge.metTarget;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              met ? Icons.emoji_events_outlined : Icons.flag_outlined,
              size: 56,
              color: met ? context.appColors.gold : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              met ? 'Challenge complete!' : 'Challenge over',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${challenge.currentValue} / ${challenge.target} ${challenge.metric.unit}',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.read<SoloChallengeBloc>().add(const ChallengeLoadRequested()),
              child: const Text('Start a new challenge'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
