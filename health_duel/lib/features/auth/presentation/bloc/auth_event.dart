import 'package:equatable/equatable.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

/// Auth Events - User actions and triggers
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Sign in with email and password
class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign in with Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Sign in with Apple
class AuthSignInWithAppleRequested extends AuthEvent {
  const AuthSignInWithAppleRequested();
}

/// Register with email and password
class AuthRegisterWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthRegisterWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Auth state changed (from stream)
class AuthStateChanged extends AuthEvent {
  final UserModel? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
