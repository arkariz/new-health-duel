import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/home/home.dart';

/// Home Page - Shows authenticated user info with responsive design
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
        appBar: AppBar(
          title: const Text('Health Duel'),
          actions: [
            // Sign out button - uses BlocSelector to avoid rebuild
            BlocSelector<HomeBloc, HomeState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading) {
                return IconButton(
                  icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: isLoading ? null : () => context.read<HomeBloc>().add(const HomeSignOutRequested()),
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
                buildWhen: (prev, curr) => prev.status != curr.status || prev.user != curr.user,
                builder:
                    (context, state) => switch (state.status) {
                      HomeStatus.initial => const _InitialView(),
                      HomeStatus.loading => _LoadingView(message: state.loadingMessage),
                      HomeStatus.loaded => state.user != null ? _AuthenticatedView(user: state.user!) : const _InitialView(),
                      HomeStatus.failure => _ErrorView(message: state.errorMessage ?? 'Unknown error'),
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
                SkeletonCard(height: context.responsiveValue(phone: 180.0, tablet: 160.0, desktop: 140.0)),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
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
            Text('Oops!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => context.read<HomeBloc>().add(const HomeLoadUserRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Authenticated view with user info
class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
        // Wait for state to change
        await context.read<HomeBloc>().stream.firstWhere((state) => !state.isLoading);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 24),
        child: ConstrainedContent(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: ResponsiveBuilder(
            phone: (context, screen) => _buildMobileLayout(context, theme),
            tablet: (context, screen) => _buildTabletLayout(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        _buildUserHeader(context, theme),
        const SizedBox(height: AppSpacing.xl),
        _buildUserDetailsCard(context, theme),
        const SizedBox(height: AppSpacing.lg),
        _buildSuccessMessage(context, theme),
        const SizedBox(height: AppSpacing.lg),
        _buildHealthCard(context, theme),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        _buildUserHeader(context, theme),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUserDetailsCard(context, theme)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _buildSuccessMessage(context, theme)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildHealthCard(context, theme),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme) {
    final avatarSize = context.responsiveValue(phone: 50.0, tablet: 60.0, desktop: 70.0);

    return Column(
      children: [
        CircleAvatar(
          radius: avatarSize,
          backgroundColor: theme.colorScheme.primary,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
            ? Text(user.name[0].toUpperCase(), style: TextStyle(fontSize: avatarSize * 0.8, color: Colors.white))
            : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          user.name,
          style: context
            .responsiveValue(phone: theme.textTheme.headlineMedium, tablet: theme.textTheme.headlineLarge)
            ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          user.email,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round())),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveValue(phone: 16.0, tablet: 20.0, desktop: 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('User Details', style: theme.textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(context, 'ID', user.id),
            _buildDetailRow(context, 'Display Name', user.name),
            _buildDetailRow(context, 'Created', _formatDate(user.createdAt)),
            _buildDetailRow(context, 'Photo URL', user.photoUrl ?? 'None'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final labelWidth = context.responsiveValue(phone: 100.0, tablet: 120.0, desktop: 140.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: labelWidth, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 2)),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context, ThemeData theme) {
    final successColor = context.appColors.success;

    return Container(
      padding: EdgeInsets.all(context.responsiveValue(phone: 16.0, tablet: 20.0)),
      decoration: BoxDecoration(
        color: successColor.withAlpha((255 * 0.1).round()),
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: successColor.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: successColor,
            size: context.responsiveValue(phone: 24.0, tablet: 28.0),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected!',
                  style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: context.responsiveValue(phone: 14.0, tablet: 16.0),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Auth + Firestore bootstrap successful.',
                  style: TextStyle(
                    color: successColor.withAlpha((255 * 0.8).round()),
                    fontSize: context.responsiveValue(phone: 12.0, tablet: 14.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.read<HomeBloc>().add(const HomeNavigateToHealthRequested()),
        child: Padding(
          padding: EdgeInsets.all(context.responsiveValue(phone: 16.0, tablet: 20.0, desktop: 24.0)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                  size: context.responsiveValue(phone: 28.0, tablet: 32.0),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step Counter',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Track your daily steps',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
