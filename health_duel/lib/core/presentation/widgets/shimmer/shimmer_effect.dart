import 'package:flutter/material.dart';

/// Shimmer effect for loading states
///
/// Provides a smooth, animated loading placeholder that indicates
/// content is being loaded. Uses gradient animation.
///
/// Example:
/// ```dart
/// Shimmer(
///   child: Container(
///     width: 200,
///     height: 20,
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(4),
///     ),
///   ),
/// )
/// ```
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, this.baseColor, this.highlightColor, this.duration = const Duration(milliseconds: 1500), this.enabled = true, super.key});

  /// The widget to apply shimmer effect to
  final Widget child;

  /// Base color of the shimmer (default: grey[300])
  final Color? baseColor;

  /// Highlight color of the shimmer (default: grey[100])
  final Color? highlightColor;

  /// Animation duration for one complete cycle
  final Duration duration;

  /// Whether shimmer animation is enabled
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.enabled) {
      _controller.repeat();
    }

    _animation = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor, highlightColor, baseColor], stops: [0.0, 0.5 + (_animation.value * 0.25), 1.0], transform: _SlidingGradientTransform(_animation.value)).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Gradient transform for sliding shimmer effect
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
