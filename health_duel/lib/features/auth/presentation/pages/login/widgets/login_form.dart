import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/router/router.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Login form with validation
class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSignIn,
    required this.onSignInWithGoogle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final VoidCallback onSignInWithGoogle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  phone: 40.0,
                  tablet: 60.0,
                  desktop: 80.0,
                ),
              ),

              // Logo/Title
              _LoginHeader(theme: theme),
              SizedBox(
                height: context.responsiveValue(
                  phone: 48.0,
                  tablet: 56.0,
                  desktop: 64.0,
                ),
              ),

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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSignIn(),
                validator: (value) => FormValidators.password(value),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Sign in button
              FilledButton(
                onPressed: onSignIn,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: const Color(0xFF060A0E),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.xlBorder,
                  ),
                ),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Divider
              _OrDivider(theme: theme),
              const SizedBox(height: AppSpacing.md),

              // Google sign in button
              OutlinedButton.icon(
                onPressed: onSignInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.xlBorder,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Register'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Test credentials hint (dev only)
              const _TestCredentialsHint(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Login header with sports-energy illustration
class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Small ALL-CAPS brand tag
        Text(
          'HEALTH DUEL',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Duel avatars illustration
        const _DuelAvatars(),
        const SizedBox(height: AppSpacing.md),

        // Headline with green highlight
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.headlineMedium,
            children: [
              const TextSpan(text: 'Challenge Your\nFriends to '),
              TextSpan(
                text: 'Stay Active',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Subtitle
        Text(
          '24-hour step-count duels. May the best stepper win.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Duel avatars side-by-side with VS badge
class _DuelAvatars extends StatelessWidget {
  const _DuelAvatars();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final opponent = context.appColors.opponent;
    final gold = context.appColors.gold;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // You — green avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, const Color(0xFF00A872)],
            ),
          ),
          child: const Center(
            child: Text('\u{1F3C3}', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // VS badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.15),
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: gold.withValues(alpha: 0.3)),
          ),
          child: Text(
            'VS',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: gold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Opponent — orange avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [opponent, const Color(0xFFCC4410)],
            ),
          ),
          child: const Center(
            child: Text('\u{1F3C3}', style: TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }
}

/// "or" divider between sign in methods
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Test credentials hint for development
class _TestCredentialsHint extends StatelessWidget {
  const _TestCredentialsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.subtleBackground,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Test Credentials',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Email: test@email.com\nPassword: test123',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
