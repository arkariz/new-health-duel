/// Common form validators
///
/// All validators return null if valid, or error message if invalid.
/// Use with Flutter's Form/TextFormField validator parameter.
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: FormValidators.email,
/// )
///
/// // Combine multiple validators
/// TextFormField(
///   validator: (value) => FormValidators.combine(value, [
///     FormValidators.required,
///     FormValidators.email,
///   ]),
/// )
/// ```
class FormValidators {
  FormValidators._();

  /// Validates required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'Please enter $fieldName' : 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password minimum length
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates password strength (uppercase, lowercase, number)
  static String? passwordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Validates password confirmation matches
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Field'} must be at most $max characters';
    }
    return null;
  }

  /// Validates phone number (basic international format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates numeric input only
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Use with required() if needed
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Field'} must be a number';
    }
    return null;
  }

  /// Combines multiple validators - stops at first error
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}

/// Extension on String for quick validation checks
extension StringValidation on String {
  /// Check if string is valid email format
  bool get isValidEmail => FormValidators.email(this) == null;

  /// Check if string meets basic password requirements (6+ chars)
  bool get isValidPassword => FormValidators.password(this) == null;

  /// Check if string meets strong password requirements
  bool get isStrongPassword => FormValidators.passwordStrength(this) == null;

  /// Check if string is valid phone number
  bool get isValidPhone => FormValidators.phone(this) == null;

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;
}
