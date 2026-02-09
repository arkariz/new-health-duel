import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Platform type for adaptive UI
enum PlatformType {
  /// iOS (iPhone, iPad)
  ios,

  /// Android
  android,

  /// Web browser
  web,

  /// macOS desktop
  macos,

  /// Windows desktop
  windows,

  /// Linux desktop
  linux,
}

/// Platform detection utilities
abstract class PlatformInfo {
  PlatformInfo._();

  /// Get current platform type
  static PlatformType get current {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.android; // Fallback
  }

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Check if running on desktop (macOS, Windows, Linux)
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on Apple platform (iOS or macOS)
  static bool get isApple => !kIsWeb && (Platform.isIOS || Platform.isMacOS);
}

/// Widget that builds different UIs per platform
///
/// Example:
/// ```dart
/// PlatformBuilder(
///   ios: (context) => CupertinoButton(...),
///   android: (context) => ElevatedButton(...),
///   web: (context) => TextButton(...),
/// )
/// ```
class PlatformBuilder extends StatelessWidget {
  const PlatformBuilder({this.ios, this.android, this.web, this.macos, this.windows, this.linux, this.mobile, this.desktop, this.fallback, super.key});

  /// Builder for iOS
  final WidgetBuilder? ios;

  /// Builder for Android
  final WidgetBuilder? android;

  /// Builder for Web
  final WidgetBuilder? web;

  /// Builder for macOS
  final WidgetBuilder? macos;

  /// Builder for Windows
  final WidgetBuilder? windows;

  /// Builder for Linux
  final WidgetBuilder? linux;

  /// Builder for mobile (iOS or Android) - used as fallback
  final WidgetBuilder? mobile;

  /// Builder for desktop (macOS, Windows, Linux) - used as fallback
  final WidgetBuilder? desktop;

  /// Fallback builder if no specific platform builder is provided
  final WidgetBuilder? fallback;

  @override
  Widget build(BuildContext context) {
    final platform = PlatformInfo.current;

    // Try specific platform first
    switch (platform) {
      case PlatformType.ios:
        if (ios != null) return ios!(context);
        if (mobile != null) return mobile!(context);
      case PlatformType.android:
        if (android != null) return android!(context);
        if (mobile != null) return mobile!(context);
      case PlatformType.web:
        if (web != null) return web!(context);
      case PlatformType.macos:
        if (macos != null) return macos!(context);
        if (desktop != null) return desktop!(context);
      case PlatformType.windows:
        if (windows != null) return windows!(context);
        if (desktop != null) return desktop!(context);
      case PlatformType.linux:
        if (linux != null) return linux!(context);
        if (desktop != null) return desktop!(context);
    }

    // Fallback
    if (fallback != null) return fallback!(context);

    return const SizedBox.shrink();
  }
}

/// Platform-adaptive value selector
///
/// Example:
/// ```dart
/// final radius = PlatformValue<double>(
///   ios: 10.0,
///   android: 4.0,
///   web: 8.0,
/// ).value;
/// ```
class PlatformValue<T> {
  const PlatformValue({
    this.ios,
    this.android,
    this.web,
    this.macos,
    this.windows,
    this.linux,
    this.mobile,
    this.desktop,
    required this.fallback,
  });

  final T? ios;
  final T? android;
  final T? web;
  final T? macos;
  final T? windows;
  final T? linux;
  final T? mobile;
  final T? desktop;
  final T fallback;

  /// Get platform-specific value
  T get value {
    final platform = PlatformInfo.current;

    switch (platform) {
      case PlatformType.ios:
        return ios ?? mobile ?? fallback;
      case PlatformType.android:
        return android ?? mobile ?? fallback;
      case PlatformType.web:
        return web ?? fallback;
      case PlatformType.macos:
        return macos ?? desktop ?? fallback;
      case PlatformType.windows:
        return windows ?? desktop ?? fallback;
      case PlatformType.linux:
        return linux ?? desktop ?? fallback;
    }
  }
}

/// Extension for platform-adaptive values in context
extension PlatformContext on BuildContext {
  /// Get platform type
  PlatformType get platform => PlatformInfo.current;

  /// Check if mobile platform
  bool get isMobilePlatform => PlatformInfo.isMobile;

  /// Check if desktop platform
  bool get isDesktopPlatform => PlatformInfo.isDesktop;

  /// Check if web platform
  bool get isWebPlatform => PlatformInfo.isWeb;

  /// Check if Apple platform (iOS or macOS)
  bool get isApplePlatform => PlatformInfo.isApple;

  /// Get platform-adaptive value
  T platformValue<T>({T? ios, T? android, T? web, T? mobile, T? desktop, required T fallback}) {
    return PlatformValue<T>(
      ios: ios,
      android: android,
      web: web,
      mobile: mobile,
      desktop: desktop,
      fallback: fallback,
    ).value;
  }
}
