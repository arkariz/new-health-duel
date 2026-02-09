import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Responsive extensions on BuildContext
///
/// Example:
/// ```dart
/// if (context.isPhone) {
///   // Mobile layout
/// }
///
/// final padding = context.responsiveValue(
///   phone: 16.0,
///   tablet: 24.0,
///   desktop: 32.0,
/// );
/// ```
extension ResponsiveContext on BuildContext {
  /// Get screen size info
  ScreenSize get screen => ScreenSize.of(this);

  /// Get device type
  DeviceType get deviceType => screen.deviceType;

  /// Check if phone
  bool get isPhone => screen.isPhone;

  /// Check if tablet
  bool get isTablet => screen.isTablet;

  /// Check if desktop
  bool get isDesktop => screen.isDesktop;

  /// Check if tablet or larger
  bool get isTabletOrLarger => screen.isTabletOrLarger;

  /// Check if landscape
  bool get isLandscape => screen.isLandscape;

  /// Check if portrait
  bool get isPortrait => screen.isPortrait;

  /// Screen width
  double get screenWidth => screen.width;

  /// Screen height
  double get screenHeight => screen.height;

  /// Get responsive value based on device type
  T responsiveValue<T>({required T phone, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }

  /// Get grid columns for current screen
  int get gridColumns => screen.gridColumns;

  /// Get horizontal padding for current screen
  double get horizontalPadding => screen.horizontalPadding;

  /// Get content max width for current screen
  double get contentMaxWidth => screen.contentMaxWidth;
}

/// Responsive extensions on num for scaling
extension ResponsiveNum on num {
  /// Scale value based on screen width
  ///
  /// Example:
  /// ```dart
  /// 16.sw(context) // 16 scaled to screen width
  /// ```
  double sw(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Base width is 375 (iPhone SE)
    return this * screenWidth / 375;
  }

  /// Scale value based on screen height
  double sh(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Base height is 812 (iPhone X)
    return this * screenHeight / 812;
  }

  /// Clamp scaled width between min and max
  double swClamped(BuildContext context, {double? min, double? max}) {
    final scaled = sw(context);
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    return scaled;
  }
}
