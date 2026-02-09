import 'package:flutter/material.dart';
import 'package:health_duel/core/error/failures.dart';

/// Visual styling configuration for displaying [Failure] types
///
/// Contains icon, color, and title for consistent error presentation.
class FailureDisplayStyle {
  /// Icon representing this failure type
  final IconData icon;

  /// Color theme for this failure type
  final Color color;

  /// User-friendly title for this failure type
  final String title;

  const FailureDisplayStyle({required this.icon, required this.color, required this.title});
}

/// Extension to get display styling from a [Failure]
///
/// Example:
/// ```dart
/// final style = failure.displayStyle;
/// Icon(style.icon, color: style.color);
/// Text(style.title);
/// ```
extension FailureDisplayStyleExtension on Failure {
  /// Get the visual styling for this failure type
  FailureDisplayStyle get displayStyle {
    return switch (this) {
      NetworkFailure() => const FailureDisplayStyle(icon: Icons.wifi_off_rounded, color: Colors.orange, title: 'Connection Problem'),
      ServerFailure() => const FailureDisplayStyle(icon: Icons.cloud_off_rounded, color: Colors.red, title: 'Server Error'),
      AuthFailure() => const FailureDisplayStyle(icon: Icons.lock_outline_rounded, color: Colors.amber, title: 'Authentication Error'),
      CacheFailure() => const FailureDisplayStyle(icon: Icons.storage_rounded, color: Colors.purple, title: 'Storage Error'),
      ValidationFailure() => const FailureDisplayStyle(icon: Icons.warning_amber_rounded, color: Colors.orange, title: 'Validation Error'),
      UnexpectedFailure() => const FailureDisplayStyle(icon: Icons.error_outline_rounded, color: Colors.grey, title: 'Something Went Wrong'),
      HealthUnavailableFailure() => const FailureDisplayStyle(icon: Icons.health_and_safety_rounded, color: Colors.teal, title: 'Health Data Unavailable'),
      HealthPermissionFailure() => const FailureDisplayStyle(icon: Icons.health_and_safety_rounded, color: Colors.teal, title: 'Health Permission Required'),
      HealthNotSupportedFailure() => const FailureDisplayStyle(icon: Icons.health_and_safety_rounded, color: Colors.teal, title: 'Health Not Supported'),
    };
  }
}
