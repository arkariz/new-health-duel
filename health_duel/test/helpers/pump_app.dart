/// Widget test utilities for pumping app with proper providers
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Mock ConnectivityCubit defaulting to online, for screens that render an
/// [AnimatedOfflineBanner] (ADR-006) but aren't testing connectivity itself.
class _DefaultOnlineConnectivityCubit extends MockCubit<ConnectivityStatus>
    implements ConnectivityCubit {}

ConnectivityCubit _buildDefaultOnlineConnectivityCubit() {
  final cubit = _DefaultOnlineConnectivityCubit();
  whenListen(
    cubit,
    const Stream<ConnectivityStatus>.empty(),
    initialState: ConnectivityStatus.online,
  );
  return cubit;
}

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
  ///
  /// Also provides a default-online [ConnectivityCubit] since
  /// [DuelListScreen] renders an [AnimatedOfflineBanner] (ADR-006).
  Future<void> pumpDuelListApp(
    Widget widget, {
    required DuelListBloc duelListBloc,
    ConnectivityCubit? connectivityCubit,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DuelListBloc>.value(value: duelListBloc),
            BlocProvider<ConnectivityCubit>.value(
              value: connectivityCubit ?? _buildDefaultOnlineConnectivityCubit(),
            ),
          ],
          child: widget,
        ),
      ),
    );
  }

  /// Pumps a widget with [CreateDuelBloc] provided
  ///
  /// Also provides a default-online [ConnectivityCubit] since
  /// [CreateDuelScreen] renders an [AnimatedOfflineBanner] (ADR-006).
  Future<void> pumpCreateDuelApp(
    Widget widget, {
    required CreateDuelBloc createDuelBloc,
    ConnectivityCubit? connectivityCubit,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CreateDuelBloc>.value(value: createDuelBloc),
            BlocProvider<ConnectivityCubit>.value(
              value: connectivityCubit ?? _buildDefaultOnlineConnectivityCubit(),
            ),
          ],
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
            builder: (_, _) => e.value,
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
