import 'package:flutter/material.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Loading view with skeleton for login page
///
/// Uses [SkeletonBuilder] fluent API for cleaner skeleton construction.
class LoginLoadingView extends StatelessWidget {
  const LoginLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = context.responsiveValue<double>(
      phone: 64,
      tablet: 80,
      desktop: 96,
    );
    final headerGap = context.responsiveValue<double>(
      phone: 32,
      tablet: 40,
      desktop: 48,
    );

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 480,
          child: Column(
            children: [
              Shimmer(
                child: SkeletonBuilder(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
                    // Logo skeleton
                    .addCircle(size: iconSize)
                    .addGap(AppSpacing.md)
                    .addText(width: 150, height: 32)
                    .addGap(AppSpacing.sm)
                    .addText(width: 220)
                    .addGap(headerGap)
                    // Form skeleton (2 fields)
                    .addBox(height: 56)
                    .addGap(AppSpacing.md)
                    .addBox(height: 56)
                    .addGap(AppSpacing.lg)
                    // Loading indicator
                    .addWidget(const CircularProgressIndicator())
                    .addGap(AppSpacing.md)
                    .build(),
              ),
              Text(
                message ?? 'Loading...',
                style: theme.textTheme.bodyLarge
              ),
            ],
          ),
        ),
      ),
    );
  }
}
