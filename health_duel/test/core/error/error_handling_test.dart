import 'package:dio/dio.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure Classes Tests', () {
    test('NetworkFailure should be created with message and code', () {
      // Arrange & Act
      const failure = NetworkFailure(
        message: 'No internet',
        errorCode: 'NET_001',
      );

      // Assert
      expect(failure.message, 'No internet');
      expect(failure.errorCode, 'NET_001');
      expect(failure, isA<Failure>());
    });

    test('ServerFailure should include status code and metadata', () {
      // Arrange & Act
      const failure = ServerFailure(
        message: 'Server error',
        errorCode: 'SRV_500',
        statusCode: 500,
        metadata: {'endpoint': '/api/data'},
      );

      // Assert
      expect(failure.message, 'Server error');
      expect(failure.statusCode, 500);
      expect(failure.metadata?['endpoint'], '/api/data');
    });

    test('Two identical failures should be equal (Equatable)', () {
      // Arrange
      const failure1 = NetworkFailure(
        message: 'No internet',
        errorCode: 'NET_001',
      );
      const failure2 = NetworkFailure(
        message: 'No internet',
        errorCode: 'NET_001',
      );

      // Assert
      expect(failure1, equals(failure2));
    });

    test('Different failures should not be equal', () {
      // Arrange
      const failure1 = NetworkFailure(message: 'No internet');
      const failure2 = ServerFailure(message: 'Server error');

      // Assert
      expect(failure1, isNot(equals(failure2)));
    });
  });

  group('ExceptionMapper Tests', () {
    test('NoInternetConnectionException should map to NetworkFailure', () {
      // Arrange
      final exception = NoInternetConnectionException(
        module: 'test',
        layer: 'data',
        function: 'getData',
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<NetworkFailure>());
      expect(failure.message.toLowerCase(), contains('internet'));
    });

    test('RequestTimeOutException should map to NetworkFailure', () {
      // Arrange
      final exception = RequestTimeOutException(
        module: 'test',
        layer: 'data',
        function: 'getData',
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<NetworkFailure>());
      expect(failure.message.toLowerCase(), contains('timeout'));
    });

    test('ApiErrorException should map to ServerFailure with metadata', () {
      // Arrange
      final exception = ApiErrorException(
        module: 'transactions',
        layer: 'data',
        function: 'getTransactions',
        response: Response(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 500,
          statusMessage: 'Internal Server Error',
        ),
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
      expect(failure.metadata?['module'], 'transactions');
      expect(failure.metadata?['function'], 'getTransactions');
    });

    test('LocalStorageCorruptionException should map to CacheFailure', () {
      // Arrange
      final exception = LocalStorageCorruptionException(
        module: 'storage',
        layer: 'data',
        function: 'readData',
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<CacheFailure>());
      expect(failure.message.toLowerCase(), contains('corruption'));
    });

    test('PermissionDeniedException should map to AuthFailure', () {
      // Arrange
      final exception = PermissionDeniedException(
        module: 'auth',
        layer: 'data',
        function: 'checkPermission',
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<AuthFailure>());
      expect(failure.message, contains('Permission'));
    });

    test('GeneralException should map to UnexpectedFailure', () {
      // Arrange
      final exception = GeneralException(
        module: 'test',
        layer: 'data',
        function: 'test',
      );

      // Act
      final failure = ExceptionMapper.toFailure(exception);

      // Assert
      expect(failure, isA<UnexpectedFailure>());
      expect((failure as UnexpectedFailure).originalException, isNotNull);
    });
  });

  group('ExceptionMapper.getUserMessage Tests', () {
    test('NetworkFailure should return user-friendly message', () {
      // Arrange
      const failure = NetworkFailure(message: 'Technical error');

      // Act
      final userMessage = ExceptionMapper.getUserMessage(failure);

      // Assert
      expect(userMessage, contains('internet'));
      expect(userMessage, isNot(contains('Technical error')));
    });

    test('ServerFailure should return user-friendly message', () {
      // Arrange
      const failure = ServerFailure(message: 'HTTP 500');

      // Act
      final userMessage = ExceptionMapper.getUserMessage(failure);

      // Assert
      expect(userMessage, contains('Server'));
      expect(userMessage, contains('try again'));
    });

    test('ValidationFailure should return original message', () {
      // Arrange
      const failure = ValidationFailure(
        message: 'Invalid email format',
      );

      // Act
      final userMessage = ExceptionMapper.getUserMessage(failure);

      // Assert
      expect(userMessage, 'Invalid email format');
    });
  });
}
