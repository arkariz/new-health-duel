import 'package:flutter/material.dart';

import 'debouncer.dart';

/// Password text field with visibility toggle and validation
///
/// Includes a built-in toggle button to show/hide password,
/// and debounced validation feedback.
///
/// Usage:
/// ```dart
/// PasswordTextField(
///   controller: _passwordController,
///   label: 'Password',
///   validator: FormValidators.password,
///   textInputAction: TextInputAction.done,
/// )
/// ```
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.onChanged,
    this.debounceMs = 300,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.autofillHints,
    super.key,
  });

  /// Controller for the text field
  final TextEditingController controller;

  /// Label text (default: 'Password')
  final String label;

  /// Validator function - returns error message or null
  final String? Function(String?)? validator;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Debounce delay in milliseconds for validation
  final int debounceMs;

  /// Keyboard action button
  final TextInputAction? textInputAction;

  /// Called when user submits
  final ValueChanged<String>? onFieldSubmitted;

  /// Whether field is enabled
  final bool enabled;

  /// Placeholder text
  final String? hintText;

  /// Helper text shown below field
  final String? helperText;

  /// Autofill hints
  final Iterable<String>? autofillHints;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
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

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
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
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: _toggleVisibility,
        tooltip: _obscureText ? 'Show password' : 'Hide password'),
        errorText: _hasInteracted ? _error : null
      ),
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      onChanged: _onChanged,
      validator: widget.validator,
    );
  }
}
