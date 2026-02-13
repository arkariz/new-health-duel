import 'package:equatable/equatable.dart';

/// Raw step data DTO from health platform.
///
/// Carries unvalidated data from HealthKit/Health Connect.
/// Use case converts this to [StepCount] entity (ADR-006).
class StepCountRaw extends Equatable {
  /// Raw step count value from platform
  final int value;

  /// Start time of the measurement period
  final DateTime startTime;

  /// End time of the measurement period
  final DateTime endTime;

  /// Source device name (e.g., "iPhone", "Pixel Watch")
  final String? sourceDevice;

  /// Whether data includes manually entered steps
  final bool hasManualEntries;

  const StepCountRaw({
    required this.value,
    required this.startTime,
    required this.endTime,
    this.sourceDevice,
    this.hasManualEntries = false,
  });

  @override
  List<Object?> get props => [
    value,
    startTime,
    endTime,
    sourceDevice,
    hasManualEntries,
  ];

  @override
  String toString() => 'StepCountRaw(value: $value, from: $startTime, to: $endTime)';
}
