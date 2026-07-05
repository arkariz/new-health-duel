import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/router/routes.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_event.dart';
import 'package:health_duel/features/friends/presentation/bloc/friends_state.dart';

class FriendsScreen extends StatefulWidget {
  final String currentUserId;
  const FriendsScreen({required this.currentUserId, super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<FriendsBloc>()
        .add(FriendsLoadRequested(widget.currentUserId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<FriendsBloc, FriendsState>(
      child: Scaffold(
        appBar: AppBar(title: const Text('Friends')),
        body: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoading || state is FriendsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FriendsError) {
              return _buildError(state.message);
            }
            if (state is FriendsLoaded) {
              return _buildLoaded(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, FriendsLoaded state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        // Search field
        _SearchField(
          controller: _searchController,
          onChanged: (query) => context.read<FriendsBloc>().add(
                FriendsSearchRequested(
                  userId: widget.currentUserId,
                  query: query,
                ),
              ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Search results section
        if (_searchController.text.length >= 2) ...[
          _SectionHeader(title: 'Search Results', isLoading: state.isSearching),
          const SizedBox(height: AppSpacing.sm),
          if (state.searchResults.isEmpty && !state.isSearching)
            _buildEmptySearch()
          else
            ...state.searchResults.map(
              (user) => _SearchResultCard(
                user: user,
                isFriend: state.friends.any((f) => f.id == user.id),
                isMutating: state.isMutating,
                onAdd: () => context.read<FriendsBloc>().add(
                      FriendAddRequested(
                        currentUserId: widget.currentUserId,
                        targetUser: user,
                      ),
                    ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // My Friends section
        _SectionHeader(title: 'My Friends', count: state.friends.length),
        const SizedBox(height: AppSpacing.sm),
        if (state.friends.isEmpty)
          _buildEmptyFriends()
        else
          ...state.friends.map(
            (friend) => _FriendCard(
              friend: friend,
              onChallenge: () => context.push(
                AppRoutes.createDuel,
                extra: widget.currentUserId,
              ),
              onRemove: () => context.read<FriendsBloc>().add(
                    FriendRemoveRequested(
                      currentUserId: widget.currentUserId,
                      friendId: friend.id,
                    ),
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyFriends() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No friends yet',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Search for players above to add them as friends',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        'No players found',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildError(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => context
                  .read<FriendsBloc>()
                  .add(FriendsLoadRequested(widget.currentUserId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Field ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search players by name...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: context.appColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: context.appColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: context.appColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final bool isLoading;

  const _SectionHeader({
    required this.title,
    this.count,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Search Result Card ────────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final UserModel user;
  final bool isFriend;
  final bool isMutating;
  final VoidCallback onAdd;

  const _SearchResultCard({
    required this.user,
    required this.isFriend,
    required this.isMutating,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Row(
        children: [
          _AvatarCircle(name: user.name, isPrimary: true),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: theme.textTheme.titleSmall),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isFriend)
            Chip(
              label: Text(
                'Friend \u2713',
                style: theme.textTheme.labelSmall?.copyWith(color: primary),
              ),
              backgroundColor: primary.withValues(alpha: 0.1),
              side: BorderSide(color: primary.withValues(alpha: 0.3)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          else
            FilledButton.tonal(
              onPressed: isMutating ? null : onAdd,
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minimumSize: const Size(0, 36),
              ),
              child: const Text('Add'),
            ),
        ],
      ),
    );
  }
}

// ─── Friend Card ──────────────────────────────────────────────────────────────

class _FriendCard extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onChallenge;
  final VoidCallback onRemove;

  const _FriendCard({
    required this.friend,
    required this.onChallenge,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Row(
        children: [
          _AvatarCircle(name: friend.name, isPrimary: false),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(friend.name, style: theme.textTheme.titleSmall),
          ),
          // Challenge button
          FilledButton.icon(
            onPressed: onChallenge,
            icon: const Icon(Icons.bolt_rounded, size: 16),
            label: const Text('Challenge'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 8,
              ),
              minimumSize: const Size(0, 36),
              textStyle: theme.textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.person_remove_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Remove friend',
            style: IconButton.styleFrom(
              minimumSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Circle ────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final String name;
  final bool isPrimary;

  const _AvatarCircle({required this.name, required this.isPrimary});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? [const Color(0xFF1E2A34), const Color(0xFF141B22)]
              : [const Color(0xFF0E1F18), const Color(0xFF0D1A23)],
        ),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Center(
        child: Text(
          _initials,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
