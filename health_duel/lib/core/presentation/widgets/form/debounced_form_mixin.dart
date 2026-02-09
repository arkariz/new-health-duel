import 'package:flutter/widgets.dart';

import 'debouncer.dart';

/// Mixin for StatefulWidgets with debounced real-time form validation
///
/// Provides field-level error tracking with automatic debouncing.
/// Useful for showing validation errors as user types.
///
/// Usage:
/// ```dart
/// class _LoginPageState extends State<LoginPage>
///     with DebouncedFormValidation {
///
///   @override
///   void dispose() {
///     disposeValidation();
///     super.dispose();
///   }
///
///   void _onEmailChanged(String value) {
///     validateWithDebounce('email', value, FormValidators.email);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return TextFormField(
///       onChanged: _onEmailChanged,
///       decoration: InputDecoration(
///         errorText: getFieldError('email'),
///       ),
///     );
///   }
/// }
/// ```
mixin DebouncedFormValidation<T extends StatefulWidget> on State<T> {
  final _debouncers = <String, Debouncer>{};
  final _fieldErrors = <String, String?>{};

  /// Get current error message for a field (null if valid)
  String? getFieldError(String field) => _fieldErrors[field];

  /// Check if a field has an error
  bool hasFieldError(String field) => _fieldErrors[field] != null;

  /// Check if all tracked fields are valid (no errors)
  bool get areFieldsValid => _fieldErrors.values.every((e) => e == null);

  /// Get count of fields with errors
  int get errorCount => _fieldErrors.values.where((e) => e != null).length;

  /// Validate a field with debounce delay
  ///
  /// The validation only runs after user stops typing for [debounceMs].
  void validateWithDebounce(String field, String? value, String? Function(String?) validator, {int debounceMs = 300}) {
    _debouncers[field] ??= Debouncer(milliseconds: debounceMs);
    _debouncers[field]!.run(() {
      if (mounted) {
        setState(() {
          _fieldErrors[field] = validator(value);
        });
      }
    });
  }

  /// Validate field immediately without debounce
  ///
  /// Use for validation on blur or form submit.
  void validateField(String field, String? value, String? Function(String?) validator) {
    setState(() {
      _fieldErrors[field] = validator(value);
    });
  }

  /// Set a custom error for a field
  void setFieldError(String field, String? error) {
    setState(() {
      _fieldErrors[field] = error;
    });
  }

  /// Clear error for a specific field
  void clearFieldError(String field) {
    setState(() {
      _fieldErrors.remove(field);
    });
  }

  /// Clear all field errors
  void clearAllErrors() {
    setState(() {
      _fieldErrors.clear();
    });
  }

  /// Dispose all debouncers - call in State.dispose()
  void disposeValidation() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
  }
}
