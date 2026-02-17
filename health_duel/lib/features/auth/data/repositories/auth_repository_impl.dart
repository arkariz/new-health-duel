import 'package:dartz/dartz.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/exception_mapper.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Auth Repository Implementation (Data Layer)
///
/// Implements [AuthRepository] interface from domain layer.
/// Responsible for:
/// - Delegating to [AuthRemoteDataSource] for Firebase operations
/// - Mapping [CoreException] to [Failure] types via [ExceptionMapper] (ADR-002)
/// - Returning [UserModel] DTO (entity creation happens in use case layer per ADR-006)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmail(
        email,
        password,
      );
      return Right(userModel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred during sign in',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return Right(userModel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred during Google sign in',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithApple() async {
    try {
      final userModel = await _remoteDataSource.signInWithApple();
      return Right(userModel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred during Apple sign in',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await _remoteDataSource.registerWithEmail(
        email,
        password,
        name,
      );
      return Right(userModel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred during registration',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    // Stream returns UserModel? directly without Either wrapper
    // Errors in stream are handled by Firebase and logged
    // Empty/null user indicates signed out state
    return _remoteDataSource.authStateChanges();
  }
}
