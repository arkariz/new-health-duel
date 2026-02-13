import 'package:equatable/equatable.dart';

import 'package:health_duel/data/session/domain/value_objects/display_name.dart';
import 'package:health_duel/data/session/domain/value_objects/email.dart';
import 'package:health_duel/data/session/domain/value_objects/password.dart';

/// User Entity (Global Domain Layer)
///
/// Represents authenticated user identity across the entire application.
/// This is a pure domain entity with value objects for type safety.
///
/// Used by:
/// - Auth feature for authentication flows
/// - Home feature for displaying user info
/// - Any feature that needs user identity
///
/// Business Logic:
/// - Email validation enforced via [Email] value object
/// - Display name validation enforced via [DisplayName] value object
/// - Password validation enforced via [Password] value object
/// - Factory methods throw [ArgumentError] if validation fails
/// - Use cases should catch exceptions and convert to Either<Failure, User>
class User extends Equatable {
  final DisplayName name;
  final Email email;
  final Password password;

  const User._({
    required this.name,
    required this.email,
    required this.password,
  });

  /// Creates a User for login flow.
  ///
  /// Throws [ArgumentError] if:
  /// - Email validation fails (empty, invalid format, too long)
  /// - Password validation fails (empty, too short)
  factory User.login({
    required String email,
    required String password,
  }) {
    return User._(
      email: Email(email), // Validates email format
      password: Password(password), // Validates password (min 6 chars)
      name: DisplayName('Anonymous'), // Default name for login
    );
  }

  /// Creates a User for registration flow.
  ///
  /// Throws [ArgumentError] if:
  /// - Email validation fails (empty, invalid format, too long)
  /// - Display name validation fails (empty, too short, too long)
  /// - Password validation fails (empty, too short)
  factory User.register({
    required String email,
    required String password,
    required String name,
  }) {
    return User._(
      email: Email(email), // Validates email format
      password: Password(password), // Validates password (min 6 chars)
      name: DisplayName(name), // Validates display name
    );
  }

  @override
  List<Object?> get props => [name, email, password];
}
