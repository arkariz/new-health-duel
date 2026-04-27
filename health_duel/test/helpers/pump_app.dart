/// Widget test utilities for pumping app with proper providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';

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

  /// Pumps a widget with [DuelListBloc] provided
  Future<void> pumpDuelListApp(
    Widget widget, {
    required DuelListBloc duelListBloc,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: BlocProvider<DuelListBloc>.value(
          value: duelListBloc,
          child: widget,
        ),
      ),
    );
  }

  /// Pumps a widget with [CreateDuelBloc] provided
  Future<void> pumpCreateDuelApp(
    Widget widget, {
    required CreateDuelBloc createDuelBloc,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: BlocProvider<CreateDuelBloc>.value(
          value: createDuelBloc,
          child: widget,
        ),
      ),
    );
  }

  /// Pumps a widget with [DuelBloc] provided
  Future<void> pumpDuelApp(
    Widget widget, {
    required DuelBloc duelBloc,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: BlocProvider<DuelBloc>.value(
          value: duelBloc,
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
