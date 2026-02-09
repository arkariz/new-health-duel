/// Responsive design utilities module
///
/// Provides breakpoints, responsive builders, and platform adaptations
/// for creating responsive layouts across phone, tablet, and desktop.
///
/// ## Screen Size Detection
/// ```dart
/// // Using extensions
/// if (context.isPhone) {
///   // Mobile layout
/// } else if (context.isTablet) {
///   // Tablet layout
/// }
///
/// // Get screen info
/// final screen = context.screen;
/// print(screen.deviceType); // DeviceType.phone
/// print(screen.gridColumns); // 4
/// ```
///
/// ## Responsive Builders
/// ```dart
/// // Builder with callbacks
/// ResponsiveBuilder(
///   phone: (context, screen) => MobileLayout(),
///   tablet: (context, screen) => TabletLayout(),
///   desktop: (context, screen) => DesktopLayout(),
/// )
///
/// // Simple widget switch
/// ResponsiveWidget(
///   phone: MobileLayout(),
///   tablet: TabletLayout(),
/// )
///
/// // Value selector
/// final columns = context.responsiveValue(
///   phone: 1,
///   tablet: 2,
///   desktop: 3,
/// );
/// ```
///
/// ## Constrained Content
/// ```dart
/// // Auto max-width for larger screens
/// ConstrainedContent(
///   maxWidth: 800,
///   child: MyContent(),
/// )
///
/// // Responsive grid
/// ResponsiveGrid(
///   phoneColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 3,
///   children: [...],
/// )
/// ```
///
/// ## Platform Adaptations
/// ```dart
/// // Platform-specific widgets
/// PlatformBuilder(
///   ios: (context) => CupertinoButton(...),
///   android: (context) => ElevatedButton(...),
/// )
///
/// // Platform checks
/// if (context.isApplePlatform) {
///   // iOS or macOS styling
/// }
/// ```
library;

export 'breakpoints.dart';
export 'platform_adaptive.dart';
export 'responsive_builder.dart';
export 'responsive_extensions.dart';
