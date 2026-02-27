import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

class AuthenticatedView extends StatelessWidget {
  const AuthenticatedView({
    super.key, 
    required this.children,
    required this.onRefresh,
  });

  final List<Widget> children;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.lg,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}