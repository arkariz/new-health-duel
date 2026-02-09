/// Shimmer loading widgets module
///
/// Provides shimmer effect and skeleton placeholders for loading states.
///
/// ## Core Effect
/// ```dart
/// Shimmer(
///   child: Container(
///     width: 200,
///     height: 20,
///     color: Colors.white,
///   ),
/// )
/// ```
///
/// ## Basic Shapes
/// ```dart
/// SkeletonBox(width: 100, height: 20)
/// SkeletonCircle(size: 48)
/// SkeletonText(widthFactor: 0.8)
/// ```
///
/// ## Pre-built Layouts
/// ```dart
/// // For lists
/// ListView.builder(
///   itemCount: 5,
///   itemBuilder: (_, __) => SkeletonListTile(),
/// )
///
/// // For cards
/// SkeletonCard(height: 120)
///
/// // For forms
/// SkeletonForm(fieldCount: 3)
///
/// // For grids
/// SkeletonGrid(itemCount: 6, crossAxisCount: 2)
/// ```
///
/// ## Builder & Factory
/// ```dart
/// // Fluent builder
/// SkeletonBuilder()
///   .addText(widthFactor: 0.6, height: 24)
///   .addGap(16)
///   .addListTile()
///   .build()
///
/// // Pre-built patterns
/// SkeletonFactory.profile()
/// SkeletonFactory.detail()
/// SkeletonFactory.list(itemCount: 10)
/// SkeletonFactory.dashboard()
/// ```
library;

export 'shimmer_effect.dart';
export 'skeleton_builder.dart';
export 'skeleton_layouts.dart';
export 'skeleton_shapes.dart';
