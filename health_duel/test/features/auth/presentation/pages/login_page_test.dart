// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:health_duel/features/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockConnectivityCubit mockConnectivityCubit;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockConnectivityCubit = MockConnectivityCubit();

    // Default: AuthInitial state
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );

    // Default: Online status
    when(
      () => mockConnectivityCubit.state,
    ).thenReturn(ConnectivityStatus.online);
    whenListen(
      mockConnectivityCubit,
      Stream<ConnectivityStatus>.empty(),
      initialState: ConnectivityStatus.online,
    );
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ConnectivityCubit>.value(value: mockConnectivityCubit),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage', () {
    group('renders', () {
      testWidgets('all form elements correctly', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Title
        expect(find.text('Health Duel'), findsOneWidget);
        expect(
          find.text('Challenge your friends to stay active!'),
          findsOneWidget,
        );

        // Form fields (ValidatedTextField has TextFormField inside)
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);

        // Buttons
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Register'), findsOneWidget);

        // Test credentials hint
        expect(find.text('Test Credentials'), findsOneWidget);
      });

      testWidgets(
        'renders loading view with custom message when state is AuthLoading',
        (tester) async {
          when(
            () => mockAuthBloc.state,
          ).thenReturn(const AuthLoading(message: 'Signing in...'));
          whenListen(
            mockAuthBloc,
            Stream<AuthState>.empty(),
            initialState: const AuthLoading(message: 'Signing in...'),
          );

          await tester.pumpWidget(buildSubject());

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          // The loading view shows the message from AuthLoading state
          expect(find.textContaining('Signing in'), findsOneWidget);
        },
      );
    });

    group('form validation', () {
      testWidgets('shows error when email is empty on submit', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter email'), findsOneWidget);
      });

      testWidgets('shows error when password is empty on submit', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        // Enter valid email but no password
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@email.com',
        );
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter password'), findsOneWidget);
      });

      testWidgets('shows error when password is too short on submit', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        // Enter valid email and short password
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@email.com',
        );
        await tester.enterText(find.byType(TextFormField).last, '123');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      });
    });

    group('sign in', () {
      testWidgets(
        'dispatches AuthSignInWithEmailRequested when form is valid',
        (tester) async {
          await tester.pumpWidget(buildSubject());

          // Enter valid credentials
          await tester.enterText(
            find.byType(TextFormField).first,
            'test@email.com',
          );
          await tester.enterText(find.byType(TextFormField).last, 'test123');
          await tester.tap(find.text('Sign In'));
          await tester.pump();

          verify(
            () => mockAuthBloc.add(
              const AuthSignInWithEmailRequested(
                email: 'test@email.com',
                password: 'test123',
              ),
            ),
          ).called(1);
        },
      );

      testWidgets('does not dispatch when form is invalid', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        verifyNever(() => mockAuthBloc.add(any()));
      });
    });

    group('sign in with Google', () {
      testWidgets('dispatches AuthSignInWithGoogleRequested on tap', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        // Scroll to make Google button visible
        await tester.ensureVisible(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Google'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthSignInWithGoogleRequested()),
        ).called(1);
      });
    });

    group('connectivity', () {
      testWidgets('shows offline banner when offline', (tester) async {
        when(
          () => mockConnectivityCubit.state,
        ).thenReturn(ConnectivityStatus.offline);
        whenListen(
          mockConnectivityCubit,
          Stream<ConnectivityStatus>.empty(),
          initialState: ConnectivityStatus.offline,
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('No internet connection'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      });

      testWidgets('hides offline banner when online', (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.text('No internet connection'), findsNothing);
      });
    });

    group('state listeners', () {
      // Note: Error handling is now done via EffectListener + global effect handlers.
      // The snackbar is shown by effect_handlers.dart when AuthShowError effect is emitted.
      // This test validates that the UI correctly transitions between states.
      testWidgets('transitions from loading to form when auth fails', (
        tester,
      ) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
        whenListen(
          mockAuthBloc,
          Stream<AuthState>.fromIterable([
            const AuthLoading(message: 'Signing in...'),
            const AuthUnauthenticated(), // Error is shown via effect, state goes to Unauthenticated
          ]),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump(); // Process first state (AuthLoading)
        await tester.pump(); // Process second state (AuthUnauthenticated)
        await tester.pumpAndSettle();

        // Form should be visible again after auth failure
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });
    });
  });
}
