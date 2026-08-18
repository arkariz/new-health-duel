import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/data/datasources/solo_challenge_firestore_datasource.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/repositories/solo_challenge_repository.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_metric.dart';

class SoloChallengeRepositoryImpl implements SoloChallengeRepository {
  const SoloChallengeRepositoryImpl(this._dataSource);
  final SoloChallengeFirestoreDataSource _dataSource;

  @override
  Future<Either<Failure, SoloChallenge>> startChallenge({
    required String userId,
    required int target,
    DuelMetric metric = DuelMetric.steps,
  }) async {
    try {
      final dto = await _dataSource.startChallenge(
        userId: userId,
        target: target,
        metric: metric,
      );
      return Right(dto.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to start challenge',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, SoloChallenge?>> getActiveChallenge(
    String userId,
  ) async {
    try {
      final dto = await _dataSource.getActiveChallenge(userId);
      return Right(dto?.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to load active challenge',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, SoloChallenge>> completeChallenge({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final dto = await _dataSource.completeChallenge(
        userId: userId,
        challengeId: challengeId,
      );
      return Right(dto.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to complete challenge',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<SoloChallenge>>> getChallengeHistory(
    String userId,
  ) async {
    try {
      final dtos = await _dataSource.getChallengeHistory(userId);
      return Right(dtos.map((d) => d.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to load challenge history',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, SoloChallenge>> updateProgress({
    required String userId,
    required String challengeId,
    required int value,
  }) async {
    try {
      final dto = await _dataSource.updateProgress(
        userId: userId,
        challengeId: challengeId,
        value: value,
      );
      return Right(dto.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to update challenge progress',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Stream<Either<Failure, SoloChallenge>> watchChallenge({
    required String userId,
    required String challengeId,
  }) {
    try {
      return _dataSource
          .watchChallenge(userId: userId, challengeId: challengeId)
          .map((dto) {
        return Right<Failure, SoloChallenge>(dto.toEntity());
      }).handleError((Object error) {
        return Left<Failure, SoloChallenge>(
          ServerFailure(message: 'Failed to watch challenge: $error'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(message: 'Failed to watch challenge: $e')),
      );
    }
  }
}
