/// Widget test utilities for pumping app with proper providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

/// Pumps a widget with required providers for testing
///
/// Usage:
/// ```dart
/// await tester.pumpApp(
///   const LoginPage(),
///   authBloc: mockAuthBloc,
/// );
/// ```
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    required AuthBloc authBloc,
    GoRouter? router,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: widget,
        ),
      ),
    );
  }

  /// Pumps widget with GoRouter for navigation testing
  Future<void> pumpRoutedApp({
    required AuthBloc authBloc,
    required GoRouter router,
  }) async {
    await pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
  }
}

/// Creates a simple GoRouter for testing
GoRouter createTestRouter({
  required String initialLocation,
  required Map<String, Widget> routes,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: routes.entries
        .map(
          (e) => GoRoute(
            path: e.key,
            builder: (_, __) => e.value,
          ),
        )
        .toList(),
  );
}

/// Extension to easily mock AuthBloc states
extension MockAuthBlocX on AuthBloc {
  /// Stub the state for widget tests
  void stubState(AuthState state) {
    // This is handled by whenListen in bloc_test
  }
}
