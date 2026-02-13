import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:health_duel/core/theme/app_theme.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';

class HealthDuelApp extends StatelessWidget {
  const HealthDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide both AuthBloc and ConnectivityCubit as singletons from DI
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: MaterialApp.router(
        title: AppConfig.env.appName,
        debugShowCheckedModeBanner: AppConfig.env.isDebug,

        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follow system theme
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
