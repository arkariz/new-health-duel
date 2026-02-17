import 'package:flutter/material.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Loading view with skeleton for register page
///
/// Uses [SkeletonBuilder] fluent API for cleaner skeleton construction.
class RegisterLoadingView extends StatelessWidget {
  const RegisterLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = context.responsiveValue(
      phone: 64.0,
      tablet: 80.0,
      desktop: 96.0,
    );
    final headerGap = context.responsiveValue(
      phone: 32.0,
      tablet: 40.0,
      desktop: 48.0,
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
                    // Icon skeleton
                    .addCircle(size: iconSize)
                    .addGap(AppSpacing.md)
                    .addText(width: 180, height: 32)
                    .addGap(AppSpacing.sm)
                    .addText(width: 240)
                    .addGap(headerGap)
                    // Form skeleton (4 fields)
                    .addBox(height: 56)
                    .addGap(AppSpacing.md)
                    .addBox(height: 56)
                    .addGap(AppSpacing.md)
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
                message ?? 'Creating your account...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
