import 'package:flutter/widgets.dart';

/// Device type based on screen width
enum DeviceType {
  /// Phone: < 600dp
  phone,

  /// Tablet: 600dp - 1024dp
  tablet,

  /// Desktop: > 1024dp
  desktop,
}

/// Screen size breakpoints
///
/// Based on Material Design responsive layout grid:
/// https://m3.material.io/foundations/layout/applying-layout
abstract class Breakpoints {
  Breakpoints._();

  /// Phone max width (compact)
  static const double phone = 599;

  /// Tablet min width (medium)
  static const double tablet = 600;

  /// Desktop min width (expanded)
  static const double desktop = 1024;

  /// Large desktop min width (extra-large)
  static const double largeDesktop = 1440;

  /// Get device type from width
  static DeviceType fromWidth(double width) {
    if (width < tablet) return DeviceType.phone;
    if (width < desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Get device type from BuildContext
  static DeviceType fromContext(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }
}

/// Screen size information
class ScreenSize {
  const ScreenSize({required this.width, required this.height, required this.deviceType, required this.orientation});

  /// Create from BuildContext
  factory ScreenSize.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ScreenSize(
      width: size.width,
      height: size.height,
      deviceType: Breakpoints.fromWidth(size.width),
      orientation: size.width > size.height ? Orientation.landscape : Orientation.portrait,
    );
  }

  /// Screen width in logical pixels
  final double width;

  /// Screen height in logical pixels
  final double height;

  /// Device type classification
  final DeviceType deviceType;

  /// Screen orientation
  final Orientation orientation;

  /// Check if phone
  bool get isPhone => deviceType == DeviceType.phone;

  /// Check if tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Check if tablet or larger
  bool get isTabletOrLarger => deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;

  /// Check if landscape orientation
  bool get isLandscape => orientation == Orientation.landscape;

  /// Check if portrait orientation
  bool get isPortrait => orientation == Orientation.portrait;

  /// Get number of columns for grid layouts
  int get gridColumns {
    switch (deviceType) {
      case DeviceType.phone:
        return isLandscape ? 8 : 4;
      case DeviceType.tablet:
        return 8;
      case DeviceType.desktop:
        return 12;
    }
  }

  /// Get recommended content max width
  double get contentMaxWidth {
    switch (deviceType) {
      case DeviceType.phone:
        return double.infinity;
      case DeviceType.tablet:
        return 840;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// Get horizontal padding
  double get horizontalPadding {
    switch (deviceType) {
      case DeviceType.phone:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }
}
