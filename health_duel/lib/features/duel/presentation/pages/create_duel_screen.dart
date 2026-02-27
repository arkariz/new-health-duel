import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Create Duel Screen — Sports-energy dark aesthetic
///
/// Visual layout:
/// - "How Duels Work" info card with step icons
/// - "Select Opponent" section header
/// - Friend list: gradient avatar + name + selection state (green border)
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
  String? _selectedFriendId;

  void _createDuel() {
    if (_selectedFriendId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select a friend to challenge first'),
          backgroundColor: context.appColors.warning,
        ),
      );
      return;
    }

    // TODO: Dispatch CreateDuelRequested via BLoC
    /*
    context.read<CreateDuelBloc>().add(
      CreateDuelRequested(
        challengerId: widget.currentUserId,
        challengedId: _selectedFriendId!,
      ),
    );
    */

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Challenge sent!'),
        backgroundColor: context.appColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

          // Friend list
          Expanded(child: _buildFriendList()),

          // CTA button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedFriendId != null ? _createDuel : null,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Send Challenge'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList() {
    // TODO: Replace with BlocBuilder for real friend data
    const mockFriends = [
      _Friend(id: 'friend1', name: 'John Doe', initials: 'JD'),
      _Friend(id: 'friend2', name: 'Jane Smith', initials: 'JS'),
      _Friend(id: 'friend3', name: 'Bob Johnson', initials: 'BJ'),
      _Friend(id: 'friend4', name: 'Alice Williams', initials: 'AW'),
    ];

    if (mockFriends.isEmpty) {
      return const _NoFriendsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: mockFriends.length,
      itemBuilder: (context, index) {
        final friend = mockFriends[index];
        final isSelected = _selectedFriendId == friend.id;
        return _FriendCard(
          friend: friend,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedFriendId = friend.id),
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
                  Text(
                    step.$1,
                    style: const TextStyle(fontSize: 14),
                  ),
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
    ('👟', 'Challenge a friend to a 24-hour step competition'),
    ('⚡', 'Once accepted, the duel starts immediately'),
    ('🏆', 'Whoever walks the most steps in 24h wins'),
  ];
}

// ─── Friend Card ──────────────────────────────────────────────────────────────

class _FriendCard extends StatelessWidget {
  final _Friend friend;
  final bool isSelected;
  final VoidCallback onTap;

  const _FriendCard({
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

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
            // Avatar with gradient
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
                  friend.initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected ? primary : theme.colorScheme.onSurfaceVariant,
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
                  Text(friend.name, style: theme.textTheme.titleSmall),
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
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No Friends State ─────────────────────────────────────────────────────────

class _NoFriendsState extends StatelessWidget {
  const _NoFriendsState();

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
            Text('No Friends Yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add friends to challenge them to duels!',
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

// ─── Models ───────────────────────────────────────────────────────────────────

class _Friend {
  final String id;
  final String name;
  final String initials;

  const _Friend({
    required this.id,
    required this.name,
    required this.initials,
  });
}
