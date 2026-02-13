import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/session.dart';

/// Auth State - Represents current authentication status
///
/// Extends [UiState] to support one-shot side effects via [EffectClearable].
/// Effects are used for navigation and snackbar messages.
sealed class AuthState extends UiState with EffectClearable<AuthState> {
  const AuthState({super.effect});

  @override
  AuthState clearEffect() => _copyWithEffect(null);

  @override
  AuthState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  /// Internal copyWith for effect - each subclass handles its own data
  AuthState _copyWithEffect(UiEffect? effect);
}

/// Initial state before checking authentication
class AuthInitial extends AuthState {
  const AuthInitial({super.effect});

  @override
  List<Object?> get props => [];

  @override
  AuthState _copyWithEffect(UiEffect? effect) => AuthInitial(effect: effect);
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  /// Optional message to show during loading
  final String? message;

  const AuthLoading({this.message, super.effect});

  @override
  List<Object?> get props => [message];

  @override
  AuthState _copyWithEffect(UiEffect? effect) => AuthLoading(message: message, effect: effect);
}

/// User is authenticated with valid session
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user, {super.effect});

  @override
  List<Object?> get props => [user];

  @override
  AuthState _copyWithEffect(UiEffect? effect) => AuthAuthenticated(user, effect: effect);
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.effect});

  @override
  List<Object?> get props => [];

  @override
  AuthState _copyWithEffect(UiEffect? effect) => AuthUnauthenticated(effect: effect);
}
