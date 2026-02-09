import 'package:exception/exception.dart';
import 'package:health_duel/core/error/failures.dart';

/// Maps CoreException from infrastructure to domain Failure types
///
/// Follows [ADR-002 Exception Isolation Strategy].
/// This prevents CoreException from leaking into the domain layer.
///
/// Usage in repositories:
/// ```dart
/// class MyRepositoryImpl implements MyRepository {
///   @override
///   Future<Either<Failure, Data>> getData() async {
///     try {
///       final data = await dataSource.getData();
///       return Right(data);
///     } on CoreException catch (e) {
///       return Left(ExceptionMapper.toFailure(e));
///     }
///   }
/// }
/// ```

/// Maps CoreException from infrastructure to domain Failure types
///
/// Follows [ADR-002 Exception Isolation Strategy].
/// Prevents CoreException from leaking into the domain layer.
class ExceptionMapper {
  ExceptionMapper._();

  /// Map CoreException to appropriate Failure type (exhaustive)
  static Failure toFailure(CoreException exception) {
    return switch (exception) {
      // API Exceptions
      ApiErrorException() => ServerFailure(message: exception.message, errorCode: exception.code, statusCode: exception.response?.statusCode, metadata: {'module': exception.module, 'function': exception.function, 'layer': exception.layer}),

      // Local Storage Exceptions
      LocalStorageCorruptionException() => CacheFailure(message: exception.message ?? 'Storage corrupted', errorCode: exception.code),
      LocalStorageClosedException() => CacheFailure(message: exception.message ?? 'Storage is closed', errorCode: exception.code),
      LocalStorageAlreadyOpenedException() => CacheFailure(message: exception.message ?? 'Storage already opened', errorCode: exception.code),

      // Firebase Auth Exceptions → AuthFailure or ValidationFailure
      FireAuthUserNotFoundException() => AuthFailure(message: 'No account found with this email', errorCode: exception.code),
      FireAuthWrongPasswordException() => AuthFailure(message: 'Invalid email or password', errorCode: exception.code),
      FireAuthInvalidEmailException() => ValidationFailure(message: 'Invalid email format', errorCode: exception.code),
      FireAuthEmailAlreadyInUseException() => AuthFailure(message: 'This email is already registered', errorCode: exception.code),
      FireAuthWeakPasswordException() => ValidationFailure(message: 'Password is too weak. Use at least 6 characters', errorCode: exception.code),
      FireAuthUserDisabledException() => AuthFailure(message: 'This account has been disabled', errorCode: exception.code),
      FireAuthOperationNotAllowedException() => AuthFailure(message: 'This sign-in method is not enabled', errorCode: exception.code),
      FireAuthInvalidCredentialException() => AuthFailure(message: 'Invalid credentials. Please try again', errorCode: exception.code),
      FireAuthAccountExistsWithDifferentCredentialException() => AuthFailure(message: 'An account already exists with the same email but different sign-in method', errorCode: exception.code),
      FireAuthQuotaExceededException() => ServerFailure(message: 'Too many attempts. Please try again later', errorCode: exception.code),
      FireAuthRequiresRecentLoginException() => AuthFailure(message: 'Please sign in again to continue', errorCode: exception.code),

      // Firestore Exceptions → ServerFailure
      FirestoreException() => ServerFailure(message: 'A server error occurred. Please try again', errorCode: exception.code, metadata: {'module': exception.module, 'function': exception.function}),

      // Network Exceptions
      NoInternetConnectionException() => NetworkFailure(message: 'No internet connection. Please check your network', errorCode: exception.code),
      RequestTimeOutException() => NetworkFailure(message: 'Request timeout. Please try again', errorCode: exception.code),

      // Permission Exceptions
      PermissionDeniedException() => AuthFailure(message: exception.message ?? 'Permission denied', errorCode: exception.code),

      // Generic Exceptions
      DecodeFailedException() => UnexpectedFailure(message: exception.message, errorCode: exception.code, originalException: 'DecodeFailedException'),
      GeneralException() => UnexpectedFailure(message: exception.message, errorCode: exception.code, originalException: 'GeneralException'),

      // Fallback for unhandled exceptions
      _ => UnexpectedFailure(message: exception.message ?? 'An unexpected error occurred', errorCode: exception.code, originalException: exception.runtimeType.toString()),
    };
  }

  /// Get user-friendly message from Failure
  ///
  /// Converts technical failure messages to user-readable text.
  /// Useful for displaying errors in UI.
  static String getUserMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'Unable to connect. Please check your internet connection.',
      ServerFailure() => 'Server is unavailable. Please try again later.',
      CacheFailure() => 'Local data error. Please restart the app.',
      ValidationFailure() => failure.message,
      AuthFailure() => 'Authentication failed. Please login again.',
      UnexpectedFailure() => 'Something went wrong. Please try again.',
      HealthUnavailableFailure() => 'Health data is unavailable on this device.',
      HealthPermissionFailure() => 'Health permissions are required to access this data.',
      HealthNotSupportedFailure() => "Your device doesn't support health data tracking.",
    };
  }
}
