import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Builder widget for responsive layouts
///
/// Builds different widgets based on screen size.
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   phone: (context, screen) => MobileLayout(),
///   tablet: (context, screen) => TabletLayout(),
///   desktop: (context, screen) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.phone, this.tablet, this.desktop, super.key});

  /// Builder for phone layout (required, used as fallback)
  final Widget Function(BuildContext context, ScreenSize screen) phone;

  /// Builder for tablet layout (optional, falls back to phone)
  final Widget Function(BuildContext context, ScreenSize screen)? tablet;

  /// Builder for desktop layout (optional, falls back to tablet or phone)
  final Widget Function(BuildContext context, ScreenSize screen)? desktop;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);

    switch (screen.deviceType) {
      case DeviceType.phone:
        return phone(context, screen);
      case DeviceType.tablet:
        return (tablet ?? phone)(context, screen);
      case DeviceType.desktop:
        return (desktop ?? tablet ?? phone)(context, screen);
    }
  }
}

/// Simplified responsive builder using widget references
///
/// Example:
/// ```dart
/// ResponsiveWidget(
///   phone: MobileLayout(),
///   tablet: TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// ```
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({required this.phone, this.tablet, this.desktop, super.key});

  /// Widget for phone layout (required, used as fallback)
  final Widget phone;

  /// Widget for tablet layout (optional, falls back to phone)
  final Widget? tablet;

  /// Widget for desktop layout (optional, falls back to tablet or phone)
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);

    switch (screen.deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }
}

/// Responsive value selector
///
/// Returns different values based on screen size.
///
/// Example:
/// ```dart
/// final columns = ResponsiveValue<int>(
///   context: context,
///   phone: 1,
///   tablet: 2,
///   desktop: 3,
/// ).value;
/// ```
class ResponsiveValue<T> {
  ResponsiveValue({required BuildContext context, required this.phone, this.tablet, this.desktop}) : _screen = ScreenSize.of(context);

  final ScreenSize _screen;

  /// Value for phone layout (required, used as fallback)
  final T phone;

  /// Value for tablet layout (optional, falls back to phone)
  final T? tablet;

  /// Value for desktop layout (optional, falls back to tablet or phone)
  final T? desktop;

  /// Get the responsive value
  T get value {
    switch (_screen.deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }
}

/// Constrained content width wrapper
///
/// Centers content with max width for larger screens.
///
/// Example:
/// ```dart
/// ConstrainedContent(
///   maxWidth: 800,
///   child: MyContent(),
/// )
/// ```
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({required this.child, this.maxWidth, this.padding, this.alignment = Alignment.topCenter, super.key});

  /// Content widget
  final Widget child;

  /// Max width (defaults to screen's contentMaxWidth)
  final double? maxWidth;

  /// Padding around content
  final EdgeInsets? padding;

  /// Alignment when constrained
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);
    final effectiveMaxWidth = maxWidth ?? screen.contentMaxWidth;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: screen.horizontalPadding);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(padding: effectivePadding, child: child),
      ),
    );
  }
}

/// Responsive grid that adjusts columns based on screen size
///
/// Example:
/// ```dart
/// ResponsiveGrid(
///   phoneColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 3,
///   spacing: 16,
///   children: [...],
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.phoneColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing,
    this.shrinkWrap = true,
    this.padding,
    super.key,
  });

  /// Grid children
  final List<Widget> children;

  /// Columns for phone
  final int phoneColumns;

  /// Columns for tablet
  final int tabletColumns;

  /// Columns for desktop
  final int desktopColumns;

  /// Horizontal spacing between items
  final double spacing;

  /// Vertical spacing between rows (defaults to spacing)
  final double? runSpacing;

  /// Whether to shrink wrap
  final bool shrinkWrap;

  /// Padding around grid
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveValue<int>(context: context, phone: phoneColumns, tablet: tabletColumns, desktop: desktopColumns).value;

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: runSpacing ?? spacing,
        crossAxisSpacing: spacing,
      ),
    );
  }
}
