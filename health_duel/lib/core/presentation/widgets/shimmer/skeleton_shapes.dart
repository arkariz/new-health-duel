import 'package:flutter/material.dart';

import 'shimmer_effect.dart';

/// Rectangular skeleton placeholder box
///
/// Basic building block for skeleton loading screens.
///
/// Example:
/// ```dart
/// SkeletonBox(width: 100, height: 20)
/// SkeletonBox(height: 56, borderRadius: 8) // Full width
/// ```
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({this.width, this.height = 16, this.borderRadius = 4, super.key});

  /// Width of the skeleton box (null = fill available width)
  final double? width;

  /// Height of the skeleton box
  final double height;

  /// Border radius of corners
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: Container(width: width, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius))));
  }
}

/// Circular skeleton placeholder for avatars
///
/// Example:
/// ```dart
/// SkeletonCircle(size: 48)
/// ```
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({this.size = 48, super.key});

  /// Diameter of the circle
  final double size;

  @override
  Widget build(BuildContext context) {
    return Shimmer(child: Container(width: size, height: size, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)));
  }
}

/// Text line skeleton placeholder
///
/// Convenience widget for text placeholders.
///
/// Example:
/// ```dart
/// SkeletonText(widthFactor: 0.8) // 80% of parent width
/// SkeletonText(width: 120) // Fixed 120px width
/// ```
class SkeletonText extends StatelessWidget {
  const SkeletonText({this.width, this.widthFactor, this.height = 14, super.key});

  /// Fixed width (takes precedence over widthFactor)
  final double? width;

  /// Width as fraction of available space (0.0 to 1.0)
  final double? widthFactor;

  /// Height of the text line
  final double height;

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return SkeletonBox(width: width, height: height);
    }

    if (widthFactor != null) {
      return FractionallySizedBox(widthFactor: widthFactor, child: SkeletonBox(height: height));
    }

    return SkeletonBox(height: height);
  }
}
