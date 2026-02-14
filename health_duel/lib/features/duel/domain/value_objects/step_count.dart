import 'package:equatable/equatable.dart';

/// Step Count Value Object
///
/// Immutable value object representing step counts in a duel.
/// Validates that step counts cannot be negative.
/// Implements comparison operators for easy comparison.
class StepCount extends Equatable implements Comparable<StepCount> {
  final int value;

  /// Create step count with validation
  ///
  /// Throws [ArgumentError] if value is negative.
  StepCount(this.value) {
    if (value < 0) {
      throw ArgumentError('Step count cannot be negative: $value');
    }
  }

  /// Create zero step count
  const StepCount.zero() : value = 0;

  /// Add steps (immutable - returns new instance)
  StepCount operator +(StepCount other) {
    return StepCount(value + other.value);
  }

  /// Subtract steps (immutable - returns new instance)
  ///
  /// Result is clamped to zero (cannot go negative).
  StepCount operator -(StepCount other) {
    final result = value - other.value;
    return StepCount(result < 0 ? 0 : result);
  }

  /// Compare step counts
  @override
  int compareTo(StepCount other) => value.compareTo(other.value);

  /// Greater than operator
  bool operator >(StepCount other) => value > other.value;

  /// Less than operator
  bool operator <(StepCount other) => value < other.value;

  /// Greater than or equal operator
  bool operator >=(StepCount other) => value >= other.value;

  /// Less than or equal operator
  bool operator <=(StepCount other) => value <= other.value;

  @override
  List<Object> get props => [value];

  @override
  String toString() => value.toString();
}
