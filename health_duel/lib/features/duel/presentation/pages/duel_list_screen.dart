import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Duel List Screen — Sports-energy dark aesthetic
///
/// Visual layout:
/// - Seamless AppBar with + action
/// - Custom tab bar: Active | Pending | History
///   (no icons, underline indicator, primary color active)
/// - TabBarView with 3 tabs showing DuelCard lists
///   or themed empty states
class DuelListScreen extends StatefulWidget {
  final String currentUserId;

  const DuelListScreen({
    required this.currentUserId,
    super.key,
  });

  @override
  State<DuelListScreen> createState() => _DuelListScreenState();
}

class _DuelListScreenState extends State<DuelListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Duels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // context.push('/duel/create');
            },
            tooltip: 'New Duel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          indicatorWeight: 2,
          labelColor: primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: theme.textTheme.labelLarge,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveDuelsTab(currentUserId: widget.currentUserId),
          _PendingDuelsTab(currentUserId: widget.currentUserId),
          _HistoryTab(currentUserId: widget.currentUserId),
        ],
      ),
    );
  }
}

// ─── Active Duels Tab ─────────────────────────────────────────────────────────

class _ActiveDuelsTab extends StatelessWidget {
  final String currentUserId;

  const _ActiveDuelsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    return _EmptyState(
      icon: Icons.bolt_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'No Active Duels',
      message: 'Start a new duel to compete with friends!',
      actionLabel: 'New Duel',
      onAction: () {
        // context.push('/duel/create');
      },
    );

    // Real implementation:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DuelListError) {
          return _EmptyState(icon: Icons.error_outline_rounded, ...);
        }
        if (state is DuelListLoaded) {
          final duels = state.activeDuels;
          if (duels.isEmpty) return _EmptyState(...);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: duels.length,
            itemBuilder: (context, index) => DuelCard(
              duel: duels[index],
              currentUserId: currentUserId,
              onTap: () => context.push('/duel/active/${duels[index].id}'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
    */
  }
}

// ─── Pending Duels Tab ────────────────────────────────────────────────────────

class _PendingDuelsTab extends StatelessWidget {
  final String currentUserId;

  const _PendingDuelsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    return _EmptyState(
      icon: Icons.hourglass_empty_rounded,
      iconColor: context.appColors.warning,
      title: 'No Pending Invitations',
      message: 'You have no pending duel invitations.',
    );

    // Real implementation:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoaded) {
          final duels = state.pendingDuels;
          if (duels.isEmpty) return _EmptyState(...);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: duels.length,
            itemBuilder: (context, index) {
              final duel = duels[index];
              final isChallenger = duel.challengerId == currentUserId;
              return DuelCard(
                duel: duel,
                currentUserId: currentUserId,
                onTap: () => context.push('/duel/pending/${duel.id}'),
                onAccept: !isChallenger
                    ? () => context.read<DuelListBloc>().add(DuelAcceptRequested(duel.id))
                    : null,
                onDecline: !isChallenger
                    ? () => context.read<DuelListBloc>().add(DuelDeclineRequested(duel.id))
                    : null,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
    */
  }
}

// ─── History Tab ──────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final String currentUserId;

  const _HistoryTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    return _EmptyState(
      icon: Icons.history_rounded,
      iconColor: context.appColors.opponent,
      title: 'No Duel History',
      message: 'Complete your first duel to see your history here.',
    );

    // Real implementation:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoaded) {
          final duels = state.historyDuels;
          if (duels.isEmpty) return _EmptyState(...);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: duels.length,
            itemBuilder: (context, index) => DuelCard(
              duel: duels[index],
              currentUserId: currentUserId,
              onTap: () => context.push('/duel/result/${duels[index].id}'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
    */
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
