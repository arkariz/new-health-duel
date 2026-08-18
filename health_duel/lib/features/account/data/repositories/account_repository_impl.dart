import 'package:dartz/dartz.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/exception_mapper.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/account/data/datasources/account_remote_data_source.dart';
import 'package:health_duel/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {

  AccountRepositoryImpl({required AccountRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;
  final AccountRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, bool>> requiresPasswordReauth() async {
    try {
      return Right(_remoteDataSource.requiresPasswordReauth());
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({String? password}) async {
    try {
      await _remoteDataSource.deleteAccount(password: password);
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'An unexpected error occurred while deleting your account',
          originalException: e.toString(),
        ),
      );
    }
  }
}
