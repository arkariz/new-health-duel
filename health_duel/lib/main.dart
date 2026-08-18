import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/app.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/config/config.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';

void main() {
  // Wraps the whole app so any error escaping the Flutter framework's own
  // error zone (including ones thrown before FlutterError.onError below is
  // wired up) still reaches Crashlytics instead of just crashing silently.
  unawaited(runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup BLoC observer for debugging
    Bloc.observer = const AppBlocObserver();

    // Setup effect handlers (navigation, snackbar, dialog)
    setupEffectHandlers();

    // Initialize app configuration with flavor from launch.json (dart-define FLAVOR)
    AppConfig.init(FlavorUtil.getFlavorFromEnv());

    // Step 1 — dependencies the first frame cannot run without. Must finish
    // before runApp(): router, AuthBloc, etc. are resolved right after this.
    // Also initializes Firebase, which Crashlytics below depends on.
    await initializeDependencies();

    // Crash reporting — off in debug builds (hot reload/restart noise),
    // on for dev and prod flavors otherwise.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
      return true;
    };

    // Step 2 — dependencies safe to keep initializing in the background.
    // Deliberately not awaited; nothing in the initial UI depends on these.
    warmUpDependencies();

    // Trigger initial auth check (once, before app starts)
    getIt<AuthBloc>().add(const AuthCheckRequested());

    runApp(const HealthDuelApp());
  }, (error, stack) {
    // Errors thrown before Firebase finishes initializing above would
    // otherwise crash while trying to report themselves.
    unawaited(
      FirebaseCrashlytics.instance
        .recordError(error, stack, fatal: true)
        .catchError((_) {}),
    );
  }));
}
