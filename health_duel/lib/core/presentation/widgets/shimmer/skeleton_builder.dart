import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';

import 'skeleton_layouts.dart';
import 'skeleton_shapes.dart';

/// Builder class for creating custom skeleton layouts
///
/// Provides a fluent API to compose skeleton loading screens.
///
/// Example:
/// ```dart
/// // Simple list skeleton
/// SkeletonBuilder()
///   .addListTile()
///   .addListTile()
///   .addListTile()
///   .build()
///
/// // Custom layout
/// SkeletonBuilder()
///   .addText(widthFactor: 0.6, height: 24)
///   .addGap(16)
///   .addBox(height: 200)
///   .addGap(24)
///   .addRow([
///     SkeletonBox(width: 100, height: 40),
///     SkeletonBox(width: 100, height: 40),
///   ])
///   .build()
/// ```
class SkeletonBuilder {
  SkeletonBuilder({this.padding = const EdgeInsets.all(AppSpacing.md), this.crossAxisAlignment = CrossAxisAlignment.start});

  /// Padding around the entire skeleton
  final EdgeInsets padding;

  /// Cross axis alignment for column
  final CrossAxisAlignment crossAxisAlignment;

  final List<Widget> _children = [];

  /// Add a text line skeleton
  SkeletonBuilder addText({double? width, double? widthFactor, double height = 14}) {
    _children.add(SkeletonText(width: width, widthFactor: widthFactor, height: height));
    return this;
  }

  /// Add a rectangular box skeleton
  SkeletonBuilder addBox({double? width, double height = 16, double borderRadius = 4}) {
    _children.add(SkeletonBox(width: width, height: height, borderRadius: borderRadius));
    return this;
  }

  /// Add a circular skeleton (for avatars)
  SkeletonBuilder addCircle({double size = 48}) {
    _children.add(SkeletonCircle(size: size));
    return this;
  }

  /// Add a list tile skeleton
  SkeletonBuilder addListTile({bool hasLeading = true, bool hasTrailing = false, double titleWidthFactor = 0.6, double subtitleWidthFactor = 0.4}) {
    _children.add(SkeletonListTile(hasLeading: hasLeading, hasTrailing: hasTrailing, titleWidthFactor: titleWidthFactor, subtitleWidthFactor: subtitleWidthFactor, padding: EdgeInsets.zero));
    return this;
  }

  /// Add a card skeleton
  SkeletonBuilder addCard({double height = 120, bool hasImage = true}) {
    _children.add(SkeletonCard(height: height, hasImage: hasImage, margin: EdgeInsets.zero));
    return this;
  }

  /// Add vertical gap
  SkeletonBuilder addGap(double height) {
    _children.add(SizedBox(height: height));
    return this;
  }

  /// Add a horizontal row of widgets
  SkeletonBuilder addRow(List<Widget> children, {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start, double spacing = 16}) {
    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    _children.add(Row(mainAxisAlignment: mainAxisAlignment, children: spacedChildren));
    return this;
  }

  /// Add any custom widget
  SkeletonBuilder addWidget(Widget widget) {
    _children.add(widget);
    return this;
  }

  /// Add a divider
  SkeletonBuilder addDivider({double height = 1, double indent = 0}) {
    _children.add(Divider(height: height * 2, indent: indent, endIndent: indent));
    return this;
  }

  /// Build the final skeleton widget
  Widget build() {
    return Padding(padding: padding, child: Column(crossAxisAlignment: crossAxisAlignment, children: _children));
  }

  /// Build as a scrollable widget
  Widget buildScrollable({ScrollPhysics? physics}) {
    return SingleChildScrollView(physics: physics, padding: padding, child: Column(crossAxisAlignment: crossAxisAlignment, children: _children));
  }
}

/// Factory for creating common skeleton patterns
///
/// Provides pre-built skeleton configurations for common UI patterns.
///
/// Example:
/// ```dart
/// // Profile page skeleton
/// SkeletonFactory.profile()
///
/// // Detail page skeleton
/// SkeletonFactory.detail()
///
/// // List with N items
/// SkeletonFactory.list(itemCount: 10)
/// ```
class SkeletonFactory {
  SkeletonFactory._();

  /// Creates a profile page skeleton
  ///
  /// Shows avatar, name, bio, and stats row.
  static Widget profile({EdgeInsets padding = const EdgeInsets.all(AppSpacing.lg)}) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          const SkeletonCircle(size: 80),
          const SizedBox(height: AppSpacing.md),
          const SkeletonText(widthFactor: 0.4, height: 20),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonText(widthFactor: 0.6, height: 14),
          const SizedBox(height: AppSpacing.lg),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (_) => const Column(children: [SkeletonBox(width: 40, height: 20), SizedBox(height: AppSpacing.xs), SkeletonBox(width: 60, height: 12)]))),
        ],
      ),
    );
  }

  /// Creates a detail page skeleton
  ///
  /// Shows image, title, subtitle, and content paragraphs.
  static Widget detail({EdgeInsets padding = const EdgeInsets.all(AppSpacing.md), bool hasImage = true, int paragraphCount = 3}) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[const SkeletonBox(height: 200, borderRadius: 12), const SizedBox(height: AppSpacing.md)],
          const SkeletonText(widthFactor: 0.8, height: 24),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonText(widthFactor: 0.5, height: 14),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < paragraphCount; i++) ...[const SkeletonText(height: 14), const SizedBox(height: AppSpacing.xs), const SkeletonText(height: 14), const SizedBox(height: AppSpacing.xs), const SkeletonText(widthFactor: 0.7, height: 14), const SizedBox(height: AppSpacing.md)],
        ],
      ),
    );
  }

  /// Creates a list skeleton with repeated items
  static Widget list({int itemCount = 5, bool hasLeading = true, bool hasTrailing = false, EdgeInsets padding = EdgeInsets.zero}) {
    return ListView.builder(padding: padding, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: itemCount, itemBuilder: (_, __) => SkeletonListTile(hasLeading: hasLeading, hasTrailing: hasTrailing));
  }

  /// Creates a grid skeleton
  static Widget grid({int itemCount = 6, int crossAxisCount = 2, double itemHeight = 120, EdgeInsets padding = const EdgeInsets.all(AppSpacing.md)}) {
    return SkeletonGrid(itemCount: itemCount, crossAxisCount: crossAxisCount, itemHeight: itemHeight, padding: padding);
  }

  /// Creates a form skeleton
  static Widget form({int fieldCount = 3, bool hasTitle = true, bool hasButton = true, EdgeInsets padding = const EdgeInsets.all(AppSpacing.lg)}) {
    return SkeletonForm(fieldCount: fieldCount, hasTitle: hasTitle, hasButton: hasButton, padding: padding);
  }

  /// Creates a settings/menu list skeleton
  static Widget settings({int itemCount = 6, EdgeInsets padding = EdgeInsets.zero}) {
    return ListView.separated(padding: padding, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: itemCount, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, __) => const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md), child: Row(children: [SkeletonCircle(size: 24), SizedBox(width: AppSpacing.md), Expanded(child: SkeletonText(widthFactor: 0.5, height: 16)), SkeletonBox(width: 24, height: 24, borderRadius: 4)])));
  }

  /// Creates a dashboard/stats skeleton
  static Widget dashboard({int cardCount = 4, EdgeInsets padding = const EdgeInsets.all(AppSpacing.md)}) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          // Stats row
          Row(children: List.generate(2, (_) => const Expanded(child: Card(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SkeletonBox(width: 40, height: 12), SizedBox(height: AppSpacing.sm), SkeletonBox(width: 80, height: 24)])))))),
          const SizedBox(height: AppSpacing.md),
          // Chart placeholder
          const SkeletonBox(height: 200, borderRadius: 12),
          const SizedBox(height: AppSpacing.md),
          // Recent items
          const SkeletonText(widthFactor: 0.3, height: 18),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(cardCount, (_) => const Padding(padding: EdgeInsets.only(bottom: AppSpacing.sm), child: SkeletonListTile(hasLeading: false, hasTrailing: true))),
        ],
      ),
    );
  }
}
