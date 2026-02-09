import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

import 'skeleton_shapes.dart';

/// Skeleton for list items with avatar and text lines
///
/// Example:
/// ```dart
/// ListView.builder(
///   itemCount: 5,
///   itemBuilder: (_, __) => SkeletonListTile(),
/// )
/// ```
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({this.hasLeading = true, this.hasTrailing = false, this.titleWidthFactor = 0.6, this.subtitleWidthFactor = 0.4, this.leadingSize = 40, this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12), super.key});

  /// Whether to show leading circle (avatar)
  final bool hasLeading;

  /// Whether to show trailing element
  final bool hasTrailing;

  /// Title width as fraction of available width (0.0 to 1.0)
  final double titleWidthFactor;

  /// Subtitle width as fraction of available width (0.0 to 1.0)
  final double subtitleWidthFactor;

  /// Size of leading circle
  final double leadingSize;

  /// Padding around the tile
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (hasLeading) ...[SkeletonCircle(size: leadingSize), const SizedBox(width: AppSpacing.md)],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SkeletonText(widthFactor: titleWidthFactor, height: 16), const SizedBox(height: AppSpacing.sm), SkeletonText(widthFactor: subtitleWidthFactor, height: 12)])),
          if (hasTrailing) ...[const SizedBox(width: AppSpacing.md), const SkeletonBox(width: 60, height: 32, borderRadius: 8)],
        ],
      ),
    );
  }
}

/// Skeleton for card content with optional image
///
/// Example:
/// ```dart
/// SkeletonCard(height: 120, hasImage: true)
/// ```
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.height = 120, this.hasImage = true, this.imageSize = 80, this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm), super.key});

  /// Total height of the card
  final double height;

  /// Whether to show image placeholder on left
  final bool hasImage;

  /// Size of image placeholder
  final double imageSize;

  /// Margin around the card
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (hasImage) ...[SkeletonBox(width: imageSize, height: imageSize, borderRadius: 8), const SizedBox(width: AppSpacing.md)],
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [SkeletonText(height: 18), SizedBox(height: AppSpacing.sm), SkeletonText(widthFactor: 0.6, height: 14), SizedBox(height: AppSpacing.sm), SkeletonText(widthFactor: 0.4, height: 14)])),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for form fields (login/register pages)
///
/// Example:
/// ```dart
/// SkeletonForm(fieldCount: 3, hasButton: true)
/// ```
class SkeletonForm extends StatelessWidget {
  const SkeletonForm({this.fieldCount = 2, this.hasButton = true, this.hasTitle = true, this.padding = const EdgeInsets.all(AppSpacing.lg), super.key});

  /// Number of form field skeletons to show
  final int fieldCount;

  /// Whether to show submit button skeleton
  final bool hasButton;

  /// Whether to show title and subtitle
  final bool hasTitle;

  /// Padding around the form
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasTitle) ...[
            // Title skeleton
            const Center(child: SkeletonText(widthFactor: 0.4, height: 32)),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: SkeletonText(widthFactor: 0.5, height: 16)),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Form fields
          for (int i = 0; i < fieldCount; i++) ...[const SkeletonBox(height: 56, borderRadius: 8), const SizedBox(height: AppSpacing.md)],

          if (hasButton) ...[const SizedBox(height: AppSpacing.sm), const SkeletonBox(height: 48, borderRadius: 8)],
        ],
      ),
    );
  }
}

/// Skeleton for a grid of items
///
/// Example:
/// ```dart
/// SkeletonGrid(
///   itemCount: 6,
///   crossAxisCount: 2,
/// )
/// ```
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({this.itemCount = 4, this.crossAxisCount = 2, this.itemHeight = 120, this.spacing = 16, this.padding = const EdgeInsets.all(AppSpacing.md), super.key});

  /// Number of skeleton items
  final int itemCount;

  /// Number of columns
  final int crossAxisCount;

  /// Height of each item
  final double itemHeight;

  /// Spacing between items
  final double spacing;

  /// Padding around the grid
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: spacing, crossAxisSpacing: spacing, mainAxisExtent: itemHeight),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const SkeletonBox(borderRadius: 12);
        },
      ),
    );
  }
}
