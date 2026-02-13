import 'package:dartz/dartz.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/exception_mapper.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/datasources/session_data_source.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';

/// Session Repository Implementation (Global Data Layer)
///
/// Implements [SessionRepository] interface from global domain layer.
/// Delegates to [SessionDataSource] for actual operations.
///
/// This creates a bridge between:
/// - Global session contracts (lib/data/session/domain)
/// - Any feature that provides SessionDataSource implementation
///
/// Other features depend on [SessionRepository], not on specific implementations.
class SessionRepositoryImpl implements SessionRepository {
  final SessionDataSource _sessionDataSource;

  SessionRepositoryImpl({required SessionDataSource sessionDataSource})
    : _sessionDataSource = sessionDataSource;

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final userModel = await _sessionDataSource.getCurrentUser();
      return Right(userModel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while getting current user',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _sessionDataSource.signOut();
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred during sign out',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _sessionDataSource.authStateChanges();
  }
}
