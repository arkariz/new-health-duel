import 'package:flutter/material.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';

/// Loading view with skeleton for login page
///
/// Uses [SkeletonBuilder] fluent API for cleaner skeleton construction.
class LoginLoadingView extends StatelessWidget {
  const LoginLoadingView({super.key, this.message});

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
                    // Logo skeleton
                    .addCircle(size: iconSize)
                    .addGap(16)
                    .addText(width: 150, height: 32)
                    .addGap(8)
                    .addText(width: 220)
                    .addGap(headerGap)
                    // Form skeleton (2 fields)
                    .addBox(height: 56)
                    .addGap(16)
                    .addBox(height: 56)
                    .addGap(24)
                    // Loading indicator
                    .addWidget(const CircularProgressIndicator())
                    .addGap(16)
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
