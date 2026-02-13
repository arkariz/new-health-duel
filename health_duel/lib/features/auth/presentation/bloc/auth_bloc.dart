import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

part 'auth_side_effect.dart';

/// Auth Bloc - Manages authentication state and events
///
/// Uses [EffectBloc] pattern for one-shot side effects like navigation
/// and snackbar messages (ADR-004).
///
/// State flow:
/// - [AuthInitial] → Initial state, waiting for auth check
/// - [AuthLoading] → Async operation in progress
/// - [AuthAuthenticated] → User is logged in
/// - [AuthUnauthenticated] → User is logged out
///
/// Uses generic effects from core:
/// - [NavigateGoEffect] → For navigation (home, login)
/// - [ShowSnackBarEffect] → For error/success messages
class AuthBloc extends EffectBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final RegisterWithEmail _registerWithEmail;
  final SignOut _signOut;

  StreamSubscription<UserModel?>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInWithApple signInWithApple,
    required RegisterWithEmail registerWithEmail,
    required SignOut signOut,
  }) :  _authRepository = authRepository,
        _signInWithEmail = signInWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _registerWithEmail = registerWithEmail,
        _signOut = signOut,
        _sessionRepository = sessionRepository,
  super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<AuthRegisterWithEmailRequested>(_onRegisterWithEmailRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes from Firebase
    _authStateSubscription = _authRepository.authStateChanges().listen((user) {
      add(AuthStateChanged(user));
    });
  }

  /// Check current authentication status
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Checking authentication...'));

    final result = await _sessionRepository.getCurrentUser();

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Sign in with email and password
  Future<void> _onSignInWithEmailRequested(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));

    final result = await _signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthUnauthenticated(effect: _effectAuthError(failure.message))),
      (user) => emit(AuthAuthenticated(user, effect: _effectNavigateToHome)),
    );
  }

  /// Sign in with Google
  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in with Google...'));

    final result = await _signInWithGoogle();

    result.fold(
      (failure) => emit(AuthUnauthenticated(effect: _effectAuthError(failure.message))),
      (user) => emit(AuthAuthenticated(user, effect: _effectNavigateToHome)),
    );
  }

  /// Sign in with Apple
  Future<void> _onSignInWithAppleRequested(
    AuthSignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in with Apple...'));

    final result = await _signInWithApple();

    result.fold(
      (failure) => emit(AuthUnauthenticated(effect: _effectAuthError(failure.message))),
      (user) => emit(AuthAuthenticated(user, effect: _effectNavigateToHome)),
    );
  }

  /// Register with email and password
  Future<void> _onRegisterWithEmailRequested(
    AuthRegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));

    final result = await _registerWithEmail(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    result.fold(
      (failure) => emit(AuthUnauthenticated(effect: _effectAuthError(failure.message))),
      (user) => emit(AuthAuthenticated(user, effect: _effectAccountCreated)),
    );
  }

  /// Sign out
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));

    final result = await _signOut();

    result.fold(
      (failure) {
        // Stay authenticated but show error
        if (state is AuthAuthenticated) {
          emit(state.withEffect(_effectAuthError(failure.message)));
        } else {
          emit(AuthUnauthenticated(effect: _effectAuthError(failure.message)));
        }
      },
      (_) {
        emit(AuthUnauthenticated(effect: _effectNavigateToLogin));
      }
    );
  }

  /// Handle auth state changes from Firebase stream
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    final userModel = event.user as UserModel?;

    if (userModel != null) {
      // Only emit if not already authenticated with this user
      if (state is! AuthAuthenticated || (state as AuthAuthenticated).user.id != userModel.id) {
        emit(AuthAuthenticated(userModel));
      }
    } else {
      // Only emit if not already unauthenticated
      if (state is! AuthUnauthenticated) {
        emit(const AuthUnauthenticated());
      }
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
