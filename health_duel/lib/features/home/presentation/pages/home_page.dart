import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/home/home.dart';

/// Home Page - Shows authenticated user dashboard with dark sports-energy design
///
/// Uses Pattern A: Separate Renderable vs Side-Effect State
/// - EffectListener for one-shot side effects (navigation, snackbar)
/// - BlocBuilder with buildWhen for optimized rebuilds
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EffectListener<HomeBloc, HomeState>(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            BlocSelector<HomeBloc, HomeState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading) {
                return IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded),
                  tooltip: 'Sign Out',
                  onPressed: isLoading
                      ? null
                      : () => context
                          .read<HomeBloc>()
                          .add(const HomeSignOutRequested()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Offline banner
            const AnimatedOfflineBanner(),

            // Main content - only rebuilds when status changes
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (prev, curr) =>
                    prev.status != curr.status || prev.user != curr.user,
                builder: (context, state) => switch (state.status) {
                  HomeStatus.initial => const _InitialView(),
                  HomeStatus.loading =>
                    _LoadingView(message: state.loadingMessage),
                  HomeStatus.loaded => state.user != null
                      ? _AuthenticatedView(user: state.user!)
                      : const _InitialView(),
                  HomeStatus.failure => _ErrorView(
                      message: state.errorMessage ?? 'Unknown error',
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Initial view - triggers user load
class _InitialView extends StatefulWidget {
  const _InitialView();

  @override
  State<_InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<_InitialView> {
  @override
  void initState() {
    super.initState();
    // Auto-load user on mount
    context.read<HomeBloc>().add(const HomeLoadUserRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Loading view with skeleton
class _LoadingView extends StatelessWidget {
  const _LoadingView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedContent(
        maxWidth: 600,
        child: Shimmer(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkeletonCircle(size: 100),
                const SizedBox(height: AppSpacing.md),
                const SkeletonText(width: 200),
                const SizedBox(height: AppSpacing.sm),
                const SkeletonText(width: 150),
                const SizedBox(height: AppSpacing.lg),
                SkeletonCard(
                  height: context.responsiveValue(
                    phone: 180.0,
                    tablet: 160.0,
                    desktop: 140.0,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error view with retry option
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedContent(
        maxWidth: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Oops!',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeLoadUserRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Authenticated view — dark sports-energy dashboard
class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
        await context
            .read<HomeBloc>()
            .stream
            .firstWhere((state) => !state.isLoading);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top padding for transparent AppBar
            const SizedBox(height: kToolbarHeight + AppSpacing.lg),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingHeader(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStepsHeroCard(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActiveDuelsSection(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActionsSection(context),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Greeting Header ─────────────────────────────────────────────
  Widget _buildGreetingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.name,
                style: theme.textTheme.titleLarge, // Syne bold
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.2),
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  // ── 2. Steps Hero Card ─────────────────────────────────────────────
  Widget _buildStepsHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () =>
          context.read<HomeBloc>().add(const HomeNavigateToHealthRequested()),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: AppRadius.xxlBorder,
          border: Border.all(color: context.appColors.divider),
        ),
        child: Stack(
          children: [
            // Ambient glow top-right
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            Column(
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
                // Big number + unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '—',
                      style: theme.textTheme.displayMedium?.copyWith(
                        // Syne 800
                        color: theme.colorScheme.onSurface,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'steps',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap to open Step Counter',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Progress bar placeholder
                ClipRRect(
                  borderRadius: AppRadius.smBorder,
                  child: LinearProgressIndicator(
                    value: 0,
                    minHeight: 6,
                    backgroundColor: context.appColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 steps',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Goal: 10,000',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Active Duels Section ────────────────────────────────────────
  Widget _buildActiveDuelsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Duels', style: theme.textTheme.titleLarge), // Syne
            TextButton(
              onPressed: () => context.push(AppRoutes.duels),
              child: Text(
                'See all',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Empty state card (placeholder — real duel data comes from DuelBloc)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppRadius.xlBorder,
            border: Border.all(color: context.appColors.divider),
          ),
          child: Column(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 36)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No active duels',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Challenge a friend to see who walks more!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => context.push(AppRoutes.createDuel),
                style: FilledButton.styleFrom(
                  foregroundColor: const Color(0xFF060A0E),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorder),
                ),
                child: const Text('Start a Duel'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 4. Quick Actions Grid ──────────────────────────────────────────
  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleLarge), // Syne
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: '🏃',
                label: 'Step Counter',
                subtitle: "Track today's steps",
                onTap: () => context
                    .read<HomeBloc>()
                    .add(const HomeNavigateToHealthRequested()),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionCard(
                icon: '⚔️',
                label: 'My Duels',
                subtitle: 'View all challenges',
                onTap: () => context.push(AppRoutes.duels),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

/// Quick action card for home dashboard
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: context.appColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
