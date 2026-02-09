import 'package:flutter/material.dart';

/// BuildContext Extensions
///
/// Provides convenient access to theme, media query, and navigation.
extension BuildContextExtensions on BuildContext {
  /// Access theme data
  ThemeData get theme => Theme.of(this);

  /// Access color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode is active
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get width => screenSize.width;

  /// Screen height
  double get height => screenSize.height;

  /// View padding (safe area)
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// View insets (keyboard)
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Show snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981), // Success green
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Pop route
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Check if can pop
  bool get canPop => Navigator.canPop(this);
}
