import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/health/health.dart';

/// Health Page - Shows step counter and handles health permissions
///
/// Uses Domain-Driven State Design where UI view is derived from
/// [HealthPermissionStatus] (domain) + presentation flags.
///
/// Pattern:
/// - EffectListener for one-shot side effects (navigation, snackbar)
/// - BlocBuilder with buildWhen for optimized rebuilds
/// - Boolean getters from state for view selection
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {

  @override
  void initState() {
    super.initState();

    context.read<HealthBloc>().add(const HealthInitRequested());
  }
  @override
  Widget build(BuildContext context) {
    return EffectListener<HealthBloc, HealthState>(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Step Counter'),
          actions: [
            // Refresh button - only visible when ready
            BlocSelector<HealthBloc, HealthState, bool>(
              selector: (state) => state.showReady,
              builder: (context, isReady) {
                if (!isReady) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Steps',
                  onPressed: () => context.read<HealthBloc>().add(const HealthRefreshRequested()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => context.read<HealthBloc>().add(const HealthRefreshRequested()),
          child: Column(
            children: [
              // Offline banner
              const AnimatedOfflineBanner(),
          
              // Main content
              Expanded(
                child: BlocBuilder<HealthBloc, HealthState>(
                  buildWhen: (p, c) =>
                    p.isLoading != c.isLoading ||
                    p.todaySteps != c.todaySteps ||
                    p.isRefreshing != c.isRefreshing,
                  builder: (context, state) => _buildContent(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealthState state) {
    if (state.isLoading) return const _LoadingView();
    if (state.showPermissionRequired) return const HealthPermissionView();
    return StepCounterView(stepCount: state.todaySteps!, isRefreshing: state.isRefreshing);
  }
}

/// Loading view with skeleton - also triggers health init
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ConstrainedContent(
        maxWidth: 400,
        child: Shimmer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonCircle(size: 150),
              SizedBox(height: AppSpacing.lg),
              SkeletonText(width: 120),
              SizedBox(height: AppSpacing.sm),
              SkeletonText(width: 80),
            ],
          ),
        ),
      ),
    );
  }
}


