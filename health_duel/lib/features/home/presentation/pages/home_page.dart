import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/features/home/home.dart';

/// Home Page - Shows authenticated user dashboard with dark sports-energy design
///
/// Uses Pattern A: Separate Renderable vs Side-Effect State
/// - EffectListener for one-shot side effects (navigation, snackbar)
/// - BlocBuilder with buildWhen for optimized rebuilds
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    context.read<HomeBloc>().add(const HomeLoadUserRequested());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return EffectListener<HomeBloc, HomeState>(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            BlocSelector<HomeBloc, HomeState, bool>(
              selector: (state) => state.isLoading,
              builder: (context, isLoading) {
                if (isLoading) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Sign Out',
                  onPressed: () => context.read<HomeBloc>().add(const HomeSignOutRequested()),
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
                builder: (context, state) => switch (state.status) {
                  HomeStatus.failure => ErrorView(
                    message: state.errorMessage ?? 'Unknown error',
                    onRetry: () => context.read<HomeBloc>().add(const HomeLoadUserRequested()),
                  ),
                  HomeStatus.loaded => AuthenticatedView(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(const HomeRefreshRequested());
                    },
                    children: [
                      GreetingHeaderSection(username: state.user?.name ?? ''),
                      StepsHeroCardSection(onTap: () => context.read<HomeBloc>().add(const HomeNavigateToHealthRequested())),
                      ActiveDuelsSection(
                        onTapSeeAll: () => context.push(AppRoutes.duels),
                      ),
                      QuickActionCardSection(
                        onTapNewDuel: () => context.read<HomeBloc>().add(const HomeNavigateToHealthRequested()),
                        onTapWeeklyStats: () => context.push(AppRoutes.duels),
                      ),
                    ],
                  ),
                  _ => const LoadingView()
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}