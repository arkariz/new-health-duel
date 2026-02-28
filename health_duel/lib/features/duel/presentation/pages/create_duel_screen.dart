import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_state.dart';

/// Create Duel Screen — Sports-energy dark aesthetic
///
/// Visual layout:
/// - "How Duels Work" info card with step icons
/// - "Select Opponent" section header
/// - Opponent list from Firestore: gradient avatar + name + selection state
/// - Bottom CTA: "SEND CHALLENGE" full-width FilledButton
class CreateDuelScreen extends StatefulWidget {
  final String currentUserId;

  const CreateDuelScreen({
    required this.currentUserId,
    super.key,
  });

  @override
  State<CreateDuelScreen> createState() => _CreateDuelScreenState();
}

class _CreateDuelScreenState extends State<CreateDuelScreen> {
  String? _selectedOpponentId;
  String? _selectedOpponentName;

  @override
  void initState() {
    super.initState();
    context.read<CreateDuelBloc>().add(
          CreateDuelOpponentsRequested(widget.currentUserId),
        );
  }

  void _submitDuel() {
    if (_selectedOpponentId == null || _selectedOpponentName == null) return;

    context.read<CreateDuelBloc>().add(
          CreateDuelSubmitted(
            challengerId: widget.currentUserId,
            challengedId: _selectedOpponentId!,
            challengedName: _selectedOpponentName!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<CreateDuelBloc, CreateDuelState>(
      child: BlocListener<CreateDuelBloc, CreateDuelState>(
        listenWhen: (_, current) => current is CreateDuelSuccess,
        listener: (_, __) => context.pop(),
        child: BlocBuilder<CreateDuelBloc, CreateDuelState>(
          builder: (context, state) {
            final isSubmitting = state is CreateDuelSubmitting;
            final hasSelection = _selectedOpponentId != null;

            return Scaffold(
              appBar: AppBar(title: const Text('New Challenge')),
              body: Column(
                children: [
                  // How it works card
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: _HowItWorksCard(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Text(
                          'Select Opponent',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Opponent list
                  Expanded(child: _buildOpponentList(state)),

                  // CTA button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: (hasSelection && !isSubmitting)
                              ? _submitDuel
                              : null,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.bolt_rounded),
                          label: Text(
                              isSubmitting ? 'Sending...' : 'Send Challenge'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOpponentList(CreateDuelState state) {
    if (state is CreateDuelLoadingOpponents || state is CreateDuelInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CreateDuelFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.read<CreateDuelBloc>().add(
                      CreateDuelOpponentsRequested(widget.currentUserId),
                    ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final opponents = switch (state) {
      CreateDuelReady(:final opponents) => opponents,
      CreateDuelSubmitting(:final opponents) => opponents,
      _ => <UserModel>[],
    };

    if (opponents.isEmpty) {
      return const _NoOpponentsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: opponents.length,
      itemBuilder: (context, index) {
        final opponent = opponents[index];
        final isSelected = _selectedOpponentId == opponent.id;
        return _OpponentCard(
          opponent: opponent,
          isSelected: isSelected,
          onTap: () => setState(() {
            _selectedOpponentId = opponent.id;
            _selectedOpponentName = opponent.name;
          }),
        );
      },
    );
  }
}

// ─── How It Works Card ────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'How Duels Work',
                style: theme.textTheme.titleSmall?.copyWith(color: primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.$1, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      step.$2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _steps = [
    ('👟', 'Challenge someone to a 24-hour step competition'),
    ('⚡', 'Once accepted, the duel starts immediately'),
    ('🏆', 'Whoever walks the most steps in 24h wins'),
  ];
}

// ─── Opponent Card ────────────────────────────────────────────────────────────

class _OpponentCard extends StatelessWidget {
  final UserModel opponent;
  final bool isSelected;
  final VoidCallback onTap;

  const _OpponentCard({
    required this.opponent,
    required this.isSelected,
    required this.onTap,
  });

  String get _initials {
    final parts = opponent.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return opponent.name.isNotEmpty
        ? opponent.name[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.06)
              : context.appColors.cardBackground,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isSelected ? primary : context.appColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2A34), Color(0xFF141B22)],
                ),
                border: Border.all(
                  color: isSelected
                      ? primary.withValues(alpha: 0.5)
                      : context.appColors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Name + hint
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opponent.name, style: theme.textTheme.titleSmall),
                  Text(
                    isSelected ? 'Selected ✓' : 'Tap to challenge',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primary : context.appColors.divider,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: 14, color: theme.colorScheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No Opponents State ───────────────────────────────────────────────────────

class _NoOpponentsState extends StatelessWidget {
  const _NoOpponentsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No Other Users Yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Invite friends to join Health Duel so you can challenge them!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
