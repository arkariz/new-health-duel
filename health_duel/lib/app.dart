import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_cubit.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_state.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/app_theme.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';

class HealthDuelApp extends StatelessWidget {
  const HealthDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide AuthBloc, ConnectivityCubit, and OfflineQueueCubit as
    // singletons from DI
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
        BlocProvider.value(value: getIt<OfflineQueueCubit>()),
      ],
      child: MaterialApp.router(
        title: AppConfig.env.appName,
        debugShowCheckedModeBanner: bool.tryParse(AppConfig.env.isDebugMode) ?? false,

        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: getIt<GoRouter>(),

        // App-wide offline queue notifications (ADR-006) — only ever emits
        // ShowSnackBarEffect, never navigation, since GoRouter's scope is
        // below this builder.
        builder: (context, child) => EffectListener<OfflineQueueCubit, OfflineQueueState>(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
