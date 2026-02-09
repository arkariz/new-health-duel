/// Form validation utilities and widgets
///
/// Provides validators, debouncing, and pre-built form field widgets
/// with real-time validation feedback.
///
/// ## Validators
/// ```dart
/// TextFormField(
///   validator: FormValidators.email,
/// )
///
/// // Combine validators
/// validator: (v) => FormValidators.combine(v, [
///   FormValidators.required,
///   FormValidators.email,
/// ])
/// ```
///
/// ## Pre-built Widgets
/// ```dart
/// ValidatedTextField(
///   controller: _emailController,
///   label: 'Email',
///   validator: FormValidators.email,
/// )
///
/// PasswordTextField(
///   controller: _passwordController,
///   validator: FormValidators.password,
/// )
/// ```
///
/// ## Mixin for Custom Forms
/// ```dart
/// class _MyFormState extends State<MyForm>
///     with DebouncedFormValidation {
///
///   void _onFieldChanged(String value) {
///     validateWithDebounce('field', value, FormValidators.required);
///   }
///
///   @override
///   void dispose() {
///     disposeValidation();
///     super.dispose();
///   }
/// }
/// ```
library;

export 'debounced_form_mixin.dart';
export 'debouncer.dart';
export 'form_validators.dart';
export 'password_text_field.dart';
export 'validated_text_field.dart';
