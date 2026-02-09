/// Base classes for UI effects
library;

import 'package:equatable/equatable.dart';

/// Base class for one-shot side effects
///
/// Each effect instance is unique by default via [_timestamp].
/// This ensures even identical effects are treated as different emissions.
abstract class UiEffect extends Equatable {
  /// Unique timestamp to differentiate effect instances
  final int _timestamp;

  /// Create effect with unique timestamp
  UiEffect() : _timestamp = DateTime.now().microsecondsSinceEpoch;

  /// Create effect with explicit timestamp (for const constructors)
  const UiEffect.withTimestamp(this._timestamp);

  String get effectId => '$runtimeType@$_timestamp';

  @override
  List<Object?> get props => [_timestamp];

  @override
  bool? get stringify => true;
}
