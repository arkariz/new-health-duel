import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:health_duel/features/auth/presentation/pages/login/widgets/widgets.dart';

/// Login Page with Phase 3.5 patterns
///
/// Features:
/// - [EffectListener] for navigation and snackbar (ADR-004)
/// - [AnimatedOfflineBanner] for connectivity status
/// - [ValidatedTextField] with real-time validation
/// - [PasswordTextField] with visibility toggle
/// - [ConstrainedContent] for responsive layout
/// - [Shimmer] skeleton loading
/// - [context.responsiveValue] for adaptive sizing
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                    return LoginLoadingView(message: state.message);
                  }

                  return LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSignIn: _signIn,
                    onSignInWithGoogle: _signInWithGoogle,
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
