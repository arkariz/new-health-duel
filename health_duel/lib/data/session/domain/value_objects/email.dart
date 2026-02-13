import 'package:equatable/equatable.dart';

/// Email value object with built-in validation.
///
/// Ensures email is always valid when created. Throws [ArgumentError]
/// if validation fails - use cases should catch and convert to Failure.
class Email extends Equatable {
  final String value;

  const Email._(this.value);

  /// Creates an Email value object.
  ///
  /// Throws [ArgumentError] if:
  /// - Email is empty
  /// - Email format is invalid
  /// - Email exceeds maximum length (255 characters)
  factory Email(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (value.length > 255) {
      throw ArgumentError('Email cannot exceed 255 characters');
    }

    if (!_isValidFormat(value)) {
      throw ArgumentError('Invalid email format');
    }

    return Email._(value.toLowerCase().trim());
  }

  /// Validates email format using RFC 5322 simplified regex
  static bool _isValidFormat(String email) {
    // Simplified email regex - covers most common cases
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
