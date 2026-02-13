import 'package:health_duel/data/session/domain/value_objects/display_name.dart';
import 'package:health_duel/data/session/domain/value_objects/email.dart';
import 'package:health_duel/data/session/domain/value_objects/password.dart';

/// Form validators that delegate to domain value objects.
///
/// This ensures single source of truth - business logic lives in domain,
/// presentation layer just wraps for form validation UI feedback.
///
/// Usage:
/// ```dart
/// ValidatedTextField(
///   label: 'Email',
///   validator: FormValidators.email,
/// )
/// ```
class FormValidators {
  FormValidators._(); // Prevent instantiation

  /// Email validation - delegates to [Email] value object.
  ///
  /// Returns error message or null if valid.
  ///
  /// Business rules (from Email VO):
  /// - Cannot be empty
  /// - Must be valid format (RFC 5322)
  /// - Maximum 255 characters
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email'; // User-friendly message
    }

    try {
      Email(value); // Domain validates here
      return null; // Valid
    } on ArgumentError catch (e) {
      return e.message; // Return domain error
    }
  }

  /// Display name validation - delegates to [DisplayName] value object.
  ///
  /// Returns error message or null if valid.
  ///
  /// Business rules (from DisplayName VO):
  /// - Cannot be empty or whitespace
  /// - Minimum 2 characters
  /// - Maximum 100 characters
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    try {
      DisplayName(value);
      return null;
    } on ArgumentError catch (e) {
      return e.message;
    }
  }

  /// Password validation - delegates to [Password] value object.
  ///
  /// Returns error message or null if valid.
  ///
  /// Business rules (from Password VO):
  /// - Cannot be empty
  /// - Minimum 6 characters
  /// - Maximum 128 characters
  ///
  /// For stronger validation (uppercase, lowercase, numbers, special chars),
  /// use [strongPassword] instead.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password'; // User-friendly message
    }

    try {
      Password(value); // Domain validates here
      return null;
    } on ArgumentError catch (e) {
      return e.message;
    }
  }

  /// Strong password validation - delegates to [Password.strong] factory.
  ///
  /// Use this for registration or password changes.
  /// Use [password] for login (less strict).
  ///
  /// Returns error message or null if valid.
  ///
  /// Business rules (from Password.strong):
  /// - Minimum 8 characters
  /// - Maximum 128 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character (!@#$%^&*...)
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    try {
      Password.strong(value); // Strong validation
      return null;
    } on ArgumentError catch (e) {
      return e.message;
    }
  }

  /// Password confirmation validation.
  ///
  /// Checks that confirmation matches the original password.
  static String? passwordConfirmation(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Required field validation.
  ///
  /// Generic validator for any required text field.
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Minimum length validation.
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  /// Maximum length validation.
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} cannot exceed $max characters';
    }
    return null;
  }

  /// Combine multiple validators.
  ///
  /// Runs validators in order, returns first error found.
  ///
  /// Example:
  /// ```dart
  /// validator: FormValidators.combine([
  ///   FormValidators.required,
  ///   FormValidators.email,
  /// ]),
  /// ```
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
