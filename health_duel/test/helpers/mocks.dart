/// Mock factories for testing
///
/// Uses mocktail for type-safe mocking.
/// Register fallback values in setUpAll().
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Auth Feature Mocks
// ═══════════════════════════════════════════════════════════════════════════

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockRegisterWithEmail extends Mock implements RegisterWithEmail {}

class MockSignOut extends Mock implements SignOut {}

/// Mock AuthBloc for widget testing
///
/// Usage:
/// ```dart
/// late MockAuthBloc mockAuthBloc;
///
/// setUp(() {
///   mockAuthBloc = MockAuthBloc();
/// });
///
/// // Stub state and stream
/// whenListen(
///   mockAuthBloc,
///   Stream<AuthState>.fromIterable([AuthLoading(), AuthAuthenticated(user)]),
///   initialState: AuthInitial(),
/// );
/// ```
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// Mock ConnectivityCubit for widget testing
class MockConnectivityCubit extends MockCubit<ConnectivityStatus>
    implements ConnectivityCubit {}

// ═══════════════════════════════════════════════════════════════════════════
// Fallback Values
// ═══════════════════════════════════════════════════════════════════════════

/// Register fallback values for mocktail
///
/// Call this in setUpAll() before using any mocks:
/// ```dart
/// setUpAll(() {
///   registerFallbackValues();
/// });
/// ```
void registerFallbackValues() {
  // Auth
  registerFallbackValue(Right<Failure, User>(FakeUser()));
  registerFallbackValue(const Right<Failure, User?>(null));
  registerFallbackValue(const Right<Failure, void>(null));
  registerFallbackValue(
    const Left<Failure, User>(AuthFailure(message: 'test')),
  );

  // Auth Events
  registerFallbackValue(const AuthCheckRequested());
  registerFallbackValue(
    const AuthSignInWithEmailRequested(email: '', password: ''),
  );
  registerFallbackValue(const AuthSignInWithGoogleRequested());
  registerFallbackValue(const AuthSignOutRequested());

  // Auth States
  registerFallbackValue(const AuthInitial());
}

/// Fake User for fallback registration
class FakeUser extends Fake implements User {}

// ═══════════════════════════════════════════════════════════════════════════
// Auth Mock Setup Helpers
// ═══════════════════════════════════════════════════════════════════════════

extension MockAuthRepositoryX on MockAuthRepository {
  /// Setup auth state stream with provided controller
  void setupAuthStateChanges(StreamController<UserModel?> controller) {
    when(() => authStateChanges()).thenAnswer((_) => controller.stream);
  }
}

extension MockSessionRepositoryX on MockSessionRepository {
  void setupGetCurrentUser(UserModel? userModel) {
    when(() => getCurrentUser()).thenAnswer((_) async => Right(userModel));
  }

  void setupFailure(Failure failure) {
    when(() => getCurrentUser()).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithEmailX on MockSignInWithEmail {
  /// Setup successful sign in
  void setupSuccess(UserModel user) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Right(user));
  }

  /// Setup failed sign in
  void setupFailure(Failure failure) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithGoogleX on MockSignInWithGoogle {
  void setupSuccess(UserModel user) {
    when(() => call()).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithAppleX on MockSignInWithApple {
  void setupSuccess(UserModel user) {
    when(() => call()).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}

extension MockRegisterWithEmailX on MockRegisterWithEmail {
  void setupSuccess(UserModel user) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignOutX on MockSignOut {
  void setupSuccess() {
    when(() => call()).thenAnswer((_) async => const Right(null));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}