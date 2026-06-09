import 'package:equatable/equatable.dart';
import 'package:health_duel/core/error/error.dart';

/// Display name value object with built-in validation.
///
/// Ensures display name is always valid when created. Throws [ValidationFailure]
/// if validation fails - use cases should catch and convert to Failure.
class DisplayName extends Equatable {

  /// Creates a DisplayName value object.
  ///
  /// Throws [Exception] if:
  /// - Display name is empty
  /// - Display name is only whitespace
  /// - Display name exceeds maximum length (100 characters)
  /// - Display name is shorter than minimum length (2 characters)
  factory DisplayName(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      throw const ValidationFailure(message: 'Display name cannot be empty');
    }

    if (trimmed.length < 2) {
      throw const ValidationFailure(message: 'Display name must be at least 2 characters');
    }

    if (trimmed.length > 100) {
      throw const ValidationFailure(message: 'Display name cannot exceed 100 characters');
    }

    return DisplayName._(trimmed);
  }

  const DisplayName._(this.value);
  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
