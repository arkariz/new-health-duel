import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/features/health/health.dart';

/// Health Permission View - Shown when permission not yet requested or denied
///
/// Displays a friendly prompt to grant health data access.
/// Also shown after user denies permission (they can retry).
class HealthPermissionView extends StatelessWidget {
  const HealthPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedContent(
        maxWidth: 400,
        child: Padding(
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Health icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.no_accounts,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'Grant Access to Continue',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                'To display your step count, we need access to your health data. Please grant permission to continue.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Permission button
              FilledButton.icon(
                onPressed: () => context.read<HealthBloc>().add(const HealthPermissionRequested()),
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Grant Permission'),
                style: FilledButton.styleFrom(minimumSize: const Size(250, 48)),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Privacy note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round())),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Your data stays private',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
