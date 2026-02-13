import 'package:equatable/equatable.dart';

/// Password value object with built-in validation.
///
/// Ensures password meets security requirements when created.
/// Throws [ArgumentError] if validation fails - use cases should catch
/// and convert to Failure.
class Password extends Equatable {
  final String value;

  const Password._(this.value);

  /// Creates a Password value object.
  ///
  /// Throws [ArgumentError] if:
  /// - Password is empty
  /// - Password is shorter than minimum length (6 characters)
  ///
  /// Note: For stronger security, consider adding:
  /// - Uppercase requirement
  /// - Lowercase requirement
  /// - Number requirement
  /// - Special character requirement
  /// - Maximum length (e.g., 128 chars to prevent DoS)
  factory Password(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (value.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    // Optional: Add maximum length to prevent DoS attacks
    if (value.length > 128) {
      throw ArgumentError('Password cannot exceed 128 characters');
    }

    return Password._(value);
  }

  /// Creates a Password with strong validation rules.
  ///
  /// Requires:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  ///
  /// Use this factory for registration or password changes.
  /// Use default factory for login (less strict).
  factory Password.strong(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (value.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }

    if (value.length > 128) {
      throw ArgumentError('Password cannot exceed 128 characters');
    }

    if (!_hasUppercase(value)) {
      throw ArgumentError('Password must contain at least one uppercase letter');
    }

    if (!_hasLowercase(value)) {
      throw ArgumentError('Password must contain at least one lowercase letter');
    }

    if (!_hasNumber(value)) {
      throw ArgumentError('Password must contain at least one number');
    }

    if (!_hasSpecialChar(value)) {
      throw ArgumentError(
        'Password must contain at least one special character (!@#\$%^&*)',
      );
    }

    return Password._(value);
  }

  /// Check if password contains uppercase letter
  static bool _hasUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  /// Check if password contains lowercase letter
  static bool _hasLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  /// Check if password contains number
  static bool _hasNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  /// Check if password contains special character
  static bool _hasSpecialChar(String password) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '***'; // Never expose password in toString()

  /// For debugging only - use with caution
  String toDebugString() => value;
}
