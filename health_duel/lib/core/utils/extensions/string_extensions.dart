/// String Extensions
///
/// Provides useful string manipulation and validation methods.
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get capitalizeWords {
    if (isEmpty) {
      return this;
    }
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is valid phone number (basic)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is numeric
  bool get isNumeric => num.tryParse(this) != null;

  /// Convert to double (returns 0 if invalid)
  double get toDoubleOrZero => double.tryParse(this) ?? 0.0;

  /// Convert to int (returns 0 if invalid)
  int get toIntOrZero => int.tryParse(this) ?? 0;

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) {
      return this;
    }
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Mask sensitive data (e.g., phone numbers, cards)
  String mask({
    int visibleStart = 0,
    int visibleEnd = 4,
    String maskChar = '*',
  }) {
    if (length <= visibleStart + visibleEnd) {
      return this;
    }

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final masked = maskChar * (length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }
}
