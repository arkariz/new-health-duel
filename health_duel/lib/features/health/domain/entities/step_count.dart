import 'package:equatable/equatable.dart';

/// Step count value object from HealthKit/Health Connect.
///
/// Immutable with invariants: value >= 0, startTime <= endTime.
class StepCount extends Equatable {
  final int value;
  final DateTime startTime;
  final DateTime endTime;
  final String? sourceDevice;

  /// Manual entries allowed in MVP, flag for future anti-cheat.
  final bool hasManualEntries;

  const StepCount._({
    required this.value,
    required this.startTime,
    required this.endTime,
    this.sourceDevice,
    this.hasManualEntries = false,
  });

  /// Creates with validation (throws [ArgumentError] if invalid).
  factory StepCount.create({
    required int value,
    required DateTime startTime,
    required DateTime endTime,
    String? sourceDevice,
    bool hasManualEntries = false,
  }) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'Step count cannot be negative');
    }
    if (startTime.isAfter(endTime)) {
      throw ArgumentError('startTime must be before or equal to endTime');
    }

    return StepCount._(
      value: value,
      startTime: startTime,
      endTime: endTime,
      sourceDevice: sourceDevice,
      hasManualEntries: hasManualEntries,
    );
  }

  /// Zero steps for given time range.
  factory StepCount.zero({required DateTime startTime, required DateTime endTime}) {
    return StepCount.create(value: 0, startTime: startTime, endTime: endTime);
  }

  /// Empty state for today (midnight to now).
  factory StepCount.todayEmpty() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    return StepCount.zero(startTime: midnight, endTime: now);
  }

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year && startTime.month == now.month && startTime.day == now.day;
  }

  Duration get duration => endTime.difference(startTime);
  bool get hasSteps => value > 0;
  bool get isEmpty => value == 0;

  /// Check if fully contained within period (for duel validation).
  bool isWithinPeriod(DateTime periodStart, DateTime periodEnd) {
    return !startTime.isBefore(periodStart) && !endTime.isAfter(periodEnd);
  }

  /// Check if overlaps with period.
  bool overlapsWith(DateTime periodStart, DateTime periodEnd) {
    return startTime.isBefore(periodEnd) && endTime.isAfter(periodStart);
  }

  @override
  List<Object?> get props => [value, startTime, endTime, sourceDevice, hasManualEntries];

  @override
  String toString() => 'StepCount(value: $value, from: $startTime, to: $endTime, manual: $hasManualEntries)';
}
