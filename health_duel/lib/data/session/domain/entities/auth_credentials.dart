import 'package:equatable/equatable.dart';

import 'package:health_duel/data/session/domain/value_objects/display_name.dart';
import 'package:health_duel/data/session/domain/value_objects/email.dart';
import 'package:health_duel/data/session/domain/value_objects/password.dart';

/// AuthCredentials Entity (Global Domain Layer)
///
/// Validates authentication inputs for register/login flows.
/// This is a write-side validation model using value objects for type safety.
///
/// **Purpose:**
/// - Validates email, password, and display name before sending to backend
/// - Enforces business rules at the domain boundary
/// - Throws [ArgumentError] if validation fails
///
/// **NOT for:**
/// - Storing authenticated user data (use [UserModel] instead)
/// - Displaying user information in UI (use [UserModel] instead)
/// - Holding user profile data (use [UserModel] instead)
///
/// **Architecture Note:**
/// This is a Command Model (CQRS write-side) that validates inputs.
/// [UserModel] is the Query Model (CQRS read-side) with data from backend.
/// See ADR-008 for the decision rationale.
///
/// Used by:
/// - Auth use cases for validating registration/login inputs
///
/// Business Logic:
/// - Email validation enforced via [Email] value object
/// - Display name validation enforced via [DisplayName] value object
/// - Password validation enforced via [Password] value object
/// - Factory methods throw [ArgumentError] if validation fails
/// - Use cases should catch exceptions and convert to `Either<Failure, UserModel>`
class AuthCredentials extends Equatable {
  final DisplayName name;
  final Email email;
  final Password password;

  const AuthCredentials._({
    required this.name,
    required this.email,
    required this.password,
  });

  /// Creates AuthCredentials for login flow.
  ///
  /// Validates email and password before authentication.
  ///
  /// Throws [ArgumentError] if:
  /// - Email validation fails (empty, invalid format, too long)
  /// - Password validation fails (empty, too short)
  factory AuthCredentials.forLogin({
    required String email,
    required String password,
  }) {
    return AuthCredentials._(
      email: Email(email), // Validates email format
      password: Password(password), // Validates password (min 6 chars)
      name: DisplayName('Anonymous'), // Default name for login
    );
  }

  /// Creates AuthCredentials for registration flow.
  ///
  /// Validates email, password, and display name before creating account.
  ///
  /// Throws [ArgumentError] if:
  /// - Email validation fails (empty, invalid format, too long)
  /// - Display name validation fails (empty, too short, too long)
  /// - Password validation fails (empty, too short)
  factory AuthCredentials.forRegister({
    required String email,
    required String password,
    required String name,
  }) {
    return AuthCredentials._(
      email: Email(email), // Validates email format
      password: Password(password), // Validates password (min 6 chars)
      name: DisplayName(name), // Validates display name
    );
  }

  @override
  List<Object?> get props => [name, email, password];
}
