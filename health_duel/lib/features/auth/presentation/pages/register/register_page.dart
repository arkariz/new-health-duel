import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

import 'widgets/widgets.dart';

/// Register Page with Phase 3.5 patterns
///
/// Features:
/// - [EffectListener] for navigation and snackbar (ADR-004)
/// - [AnimatedOfflineBanner] for connectivity status
/// - [ValidatedTextField] with real-time validation
/// - [PasswordTextField] with visibility toggle
/// - [ConstrainedContent] for responsive layout
/// - [Shimmer] skeleton loading
/// - [context.responsiveValue] for adaptive sizing
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Offline banner at top
          const AnimatedOfflineBanner(),

          // Main content with EffectListener
          Expanded(
            child: EffectListener<AuthBloc, AuthState>(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType || (prev is AuthLoading && curr is AuthLoading && prev.message != curr.message),
                builder: (context, state) {
                  // Show skeleton during loading
                  if (state is AuthLoading) {
                    return RegisterLoadingView(message: state.message);
                  }

                  return RegisterForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    onRegister: _register,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
