import 'package:equatable/equatable.dart';

/// Base class for all domain failures (see ADR-002 Exception Isolation)
///
/// All failures are immutable, equatable, and sealed for exhaustive handling.
sealed class Failure extends Equatable {
  /// User-facing or technical message
  final String message;

  /// Optional error code for diagnostics
  final String? errorCode;

  const Failure({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Network-related failures (e.g., no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.errorCode});

  @override
  String toString() => 'NetworkFailure(message: $message, code: $errorCode)';
}

/// Server-side failures (API errors, 5xx responses, etc.)
class ServerFailure extends Failure {
  /// HTTP status code (if available)
  final int? statusCode;

  /// Additional metadata (e.g., module, function)
  final Map<String, dynamic>? metadata;

  const ServerFailure({required super.message, super.errorCode, this.statusCode, this.metadata});

  @override
  List<Object?> get props => [message, errorCode, statusCode, metadata];

  @override
  String toString() => 'ServerFailure(message: $message, code: $errorCode, status: $statusCode, meta: $metadata)';
}

/// Local storage/cache failures (e.g., Hive corruption, read/write errors)
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.errorCode});

  @override
  String toString() => 'CacheFailure(message: $message, code: $errorCode)';
}

/// Authentication/Authorization failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.errorCode});

  @override
  String toString() => 'AuthFailure(message: $message, code: $errorCode)';
}

/// Validation failures (invalid data, business rule violations)
class ValidationFailure extends Failure {
  /// Field-level errors (e.g., {"email": "Invalid format"})
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required super.message, super.errorCode, this.fieldErrors});

  @override
  List<Object?> get props => [message, errorCode, fieldErrors];

  @override
  String toString() => 'ValidationFailure(message: $message, fields: $fieldErrors)';
}

/// Unexpected/Unknown failures (fallback)
class UnexpectedFailure extends Failure {
  /// Original exception type or message (for diagnostics)
  final String? originalException;

  const UnexpectedFailure({required super.message, super.errorCode, this.originalException});

  @override
  List<Object?> get props => [message, errorCode, originalException];

  @override
  String toString() => 'UnexpectedFailure(message: $message, original: $originalException)';
}

// ═══════════════════════════════════════════════════════════════════════════
// HEALTH FAILURES (Phase 4)
// ═══════════════════════════════════════════════════════════════════════════

/// Health platform unavailable (Health Connect not installed, HealthKit not available)
class HealthUnavailableFailure extends Failure {
  const HealthUnavailableFailure({required super.message, super.errorCode});

  @override
  String toString() => 'HealthUnavailableFailure(message: $message, code: $errorCode)';
}

/// Health platform not supported by device (older devices, unsupported hardware)
class HealthNotSupportedFailure extends Failure {
  const HealthNotSupportedFailure({required super.message, super.errorCode});

  @override
  String toString() => 'HealthNotSupportedFailure(message: $message, code: $errorCode)';
}

/// Health permission not granted or denied by user
class HealthPermissionFailure extends Failure {
  const HealthPermissionFailure({required super.message, super.errorCode});

  @override
  String toString() => 'HealthPermissionFailure(message: $message, code: $errorCode)';
}
