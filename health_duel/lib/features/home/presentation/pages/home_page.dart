import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/health/presentation/bloc/health_bloc.dart';
import 'package:health_duel/features/health/presentation/bloc/health_event.dart';
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
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadUserRequested());
    context.read<HealthBloc>().add(const HealthInitRequested());
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<HomeBloc, HomeState>(
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (prev, curr) => prev.user == null && curr.user != null,
        listener: (context, state) {
          context.read<DuelListBloc>().add(DuelListLoadRequested(state.user!.id));
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push(AppRoutes.settings),
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
                      prev.status != curr.status ||
                      prev.user != curr.user ||
                      prev.activeChallenge != curr.activeChallenge,
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
                        GreetingHeaderSection(
                          username: state.user?.name ?? '',
                          streak: state.user == null
                              ? 0
                              : StreakUpdate.effectiveCurrentStreak(
                                  currentStreak: state.user!.currentStreak,
                                  lastCompletedDate: state.user!.lastCompletedDate,
                                  nowLocal: DateTime.now(),
                                ),
                        ),
                        StepsHeroCardSection(
                          onTap: () => context.push(AppRoutes.challenge),
                          activeChallenge: state.activeChallenge,
                        ),
                        ActiveDuelsSection(
                          currentUserId: state.user?.id ?? '',
                          onTapSeeAll: () => context.push(AppRoutes.duels, extra: state.user?.id ?? ''),
                          onTapDuelCard: (duelId) => context.push(AppRoutes.duelPath(duelId), extra: state.user?.id ?? ''),
                        ),
                        QuickActionCardSection(
                          onTapNewDuel: () => context.push(AppRoutes.createDuel, extra: state.user?.id ?? ''),
                          onTapWeeklyStats: () => context.push(AppRoutes.duels, extra: state.user?.id ?? ''),
                          onTapFriends: () => context.push(AppRoutes.friends, extra: state.user?.id ?? ''),
                          onTapHealth: () => context.push(AppRoutes.health),
                        ),
                      ],
                    ),
                    _ => const LoadingView(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
