import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Register form with validation
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedContent(
        maxWidth: 480,
        padding: EdgeInsets.zero,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: context.responsiveValue(
                  phone: 24.0,
                  tablet: 40.0,
                  desktop: 56.0,
                ),
              ),

              // Header section
              const _RegisterHeader(),
              SizedBox(
                height: context.responsiveValue(
                  phone: 32.0,
                  tablet: 40.0,
                  desktop: 48.0,
                ),
              ),

              // Name field
              ValidatedTextField(
                controller: nameController,
                label: 'Full Name',
                keyboardType: TextInputType.name,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: FormValidators.required,
              ),
              const SizedBox(height: AppSpacing.md),

              // Email field with real-time validation
              ValidatedTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: FormValidators.email,
              ),
              const SizedBox(height: AppSpacing.md),

              // Password field with visibility toggle
              PasswordTextField(
                controller: passwordController,
                label: 'Password',
                textInputAction: TextInputAction.next,
                validator: (value) => FormValidators.password(value),
              ),
              const SizedBox(height: AppSpacing.md),

              // Confirm password field
              PasswordTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onRegister(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Register button
              FilledButton(
                onPressed: onRegister,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Terms and conditions hint
              const _TermsHint(),
              const SizedBox(height: AppSpacing.lg),

              // Login link
              _LoginLink(onPressed: () => context.pop()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header with icon and title
class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.person_add_outlined,
          size: context.responsiveValue(phone: 64.0, tablet: 80.0, desktop: 96.0),
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Join Health Duel',
          style: context
              .responsiveValue(
                phone: theme.textTheme.headlineMedium,
                tablet: theme.textTheme.headlineLarge,
                desktop: theme.textTheme.displaySmall,
              )
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Create an account to start challenging friends',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Terms and conditions hint text
class _TermsHint extends StatelessWidget {
  const _TermsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'By creating an account, you agree to our Terms of Service and Privacy Policy',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Login link for existing users
class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: theme.textTheme.bodyMedium),
        TextButton(onPressed: onPressed, child: const Text('Sign In')),
      ],
    );
  }
}
