import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/duel/presentation/widgets/duel_card.dart';

/// Duel List Screen - Browse all duels
///
/// Features:
/// - 3 tabs: Active, Pending, History
/// - Real-time updates for active duels
/// - Accept/Decline actions for pending duels
/// - Tap to view duel details
///
/// Each tab displays a list of [DuelCard] widgets with appropriate actions.
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Duels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create duel screen
              // TODO: Implement navigation
              // context.push('/duel/create');
            },
            tooltip: 'New Duel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.timer)),
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Duels Tab
          _ActiveDuelsTab(currentUserId: widget.currentUserId),

          // Pending Duels Tab
          _PendingDuelsTab(currentUserId: widget.currentUserId),

          // History Tab
          _HistoryTab(currentUserId: widget.currentUserId),
        ],
      ),
    );
  }
}

/// Active Duels Tab - Shows ongoing competitions
class _ActiveDuelsTab extends StatelessWidget {
  final String currentUserId;

  const _ActiveDuelsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    // This is a placeholder implementation
    return _buildPlaceholder(
      context,
      icon: Icons.timer,
      title: 'No Active Duels',
      message: 'Start a new duel to compete with friends!',
      actionLabel: 'New Duel',
      onAction: () {
        // Navigate to create duel
        // context.push('/duel/create');
      },
    );

    // Real implementation would be:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DuelListError) {
          return _buildErrorView(context, state.message);
        }

        if (state is DuelListLoaded) {
          final activeDuels = state.activeDuels;

          if (activeDuels.isEmpty) {
            return _buildPlaceholder(
              context,
              icon: Icons.timer,
              title: 'No Active Duels',
              message: 'Start a new duel to compete with friends!',
              actionLabel: 'New Duel',
              onAction: () => context.push('/duel/create'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activeDuels.length,
            itemBuilder: (context, index) {
              final duel = activeDuels[index];
              return DuelCard(
                duel: duel,
                currentUserId: currentUserId,
                onTap: () {
                  // Navigate to active duel screen
                  context.push('/duel/active/${duel.id}');
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
    */
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pending Duels Tab - Shows invitations awaiting response
class _PendingDuelsTab extends StatelessWidget {
  final String currentUserId;

  const _PendingDuelsTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    return _buildPlaceholder(
      context,
      icon: Icons.pending_actions,
      title: 'No Pending Invitations',
      message: 'You have no pending duel invitations.',
    );

    // Real implementation would be:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DuelListError) {
          return _buildErrorView(context, state.message);
        }

        if (state is DuelListLoaded) {
          final pendingDuels = state.pendingDuels;

          if (pendingDuels.isEmpty) {
            return _buildPlaceholder(
              context,
              icon: Icons.pending_actions,
              title: 'No Pending Invitations',
              message: 'You have no pending duel invitations.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: pendingDuels.length,
            itemBuilder: (context, index) {
              final duel = pendingDuels[index];
              final isChallenger = duel.challengerId == currentUserId;

              return DuelCard(
                duel: duel,
                currentUserId: currentUserId,
                onTap: () {
                  // Navigate to duel details
                  context.push('/duel/pending/${duel.id}');
                },
                onAccept: !isChallenger
                    ? () {
                        // Accept duel
                        context.read<DuelListBloc>().add(
                              DuelAcceptRequested(duel.id),
                            );
                      }
                    : null,
                onDecline: !isChallenger
                    ? () {
                        // Decline duel
                        context.read<DuelListBloc>().add(
                              DuelDeclineRequested(duel.id),
                            );
                      }
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

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// History Tab - Shows completed duels
class _HistoryTab extends StatelessWidget {
  final String currentUserId;

  const _HistoryTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BlocBuilder for real data
    return _buildPlaceholder(
      context,
      icon: Icons.history,
      title: 'No Duel History',
      message: 'Complete your first duel to see your history here.',
    );

    // Real implementation would be:
    /*
    return BlocBuilder<DuelListBloc, DuelListState>(
      builder: (context, state) {
        if (state is DuelListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DuelListError) {
          return _buildErrorView(context, state.message);
        }

        if (state is DuelListLoaded) {
          final historyDuels = state.historyDuels;

          if (historyDuels.isEmpty) {
            return _buildPlaceholder(
              context,
              icon: Icons.history,
              title: 'No Duel History',
              message: 'Complete your first duel to see your history here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: historyDuels.length,
            itemBuilder: (context, index) {
              final duel = historyDuels[index];
              return DuelCard(
                duel: duel,
                currentUserId: currentUserId,
                onTap: () {
                  // Navigate to duel result screen
                  context.push('/duel/result/${duel.id}');
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
    */
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
