import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/app.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup BLoC observer for debugging
  Bloc.observer = const AppBlocObserver();

  // Setup effect handlers (navigation, snackbar, dialog)
  setupEffectHandlers();

  // Initialize app configuration with flavor from launch.json (dart-define FLAVOR)
  AppConfig.init(FlavorUtil.getFlavorFromEnv());

  // Step 1 — dependencies the first frame cannot run without. Must finish
  // before runApp(): router, AuthBloc, etc. are resolved right after this.
  await initializeDependencies();

  // Step 2 — dependencies safe to keep initializing in the background.
  // Deliberately not awaited; nothing in the initial UI depends on these.
  warmUpDependencies();

  // Trigger initial auth check (once, before app starts)
  getIt<AuthBloc>().add(const AuthCheckRequested());

  runApp(const HealthDuelApp());
}
