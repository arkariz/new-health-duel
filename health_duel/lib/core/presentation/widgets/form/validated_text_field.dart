import 'package:flutter/material.dart';

import 'debouncer.dart';

/// Text field with built-in debounced validation feedback
///
/// Shows validation errors after user stops typing, providing
/// real-time feedback without excessive validation calls.
///
/// Usage:
/// ```dart
/// ValidatedTextField(
///   controller: _emailController,
///   label: 'Email',
///   validator: FormValidators.email,
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: Icon(Icons.email),
/// )
/// ```
class ValidatedTextField extends StatefulWidget {
  const ValidatedTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.debounceMs = 300,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.maxLines = 1,
    this.minLines,
    super.key,
  });

  /// Controller for the text field
  final TextEditingController controller;

  /// Label text shown above the field
  final String label;

  /// Validator function - returns error message or null
  final String? Function(String?)? validator;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Debounce delay in milliseconds for validation
  final int debounceMs;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Icon shown at start of field
  final Widget? prefixIcon;

  /// Icon/widget shown at end of field
  final Widget? suffixIcon;

  /// Keyboard action button
  final TextInputAction? textInputAction;

  /// Called when user submits
  final ValueChanged<String>? onFieldSubmitted;

  /// Autofill hints
  final Iterable<String>? autofillHints;

  /// Whether field is enabled
  final bool enabled;

  /// Placeholder text
  final String? hintText;

  /// Helper text shown below field
  final String? helperText;

  /// Maximum lines
  final int maxLines;

  /// Minimum lines
  final int? minLines;

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  final _debouncer = Debouncer();
  String? _error;
  bool _hasInteracted = false;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);

    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }

    if (widget.validator != null) {
      _debouncer.run(() {
        if (mounted) {
          setState(() {
            _error = widget.validator!(value);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorText: _hasInteracted ? _error : null,
      ),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: _onChanged,
      validator: widget.validator,
    );
  }
}