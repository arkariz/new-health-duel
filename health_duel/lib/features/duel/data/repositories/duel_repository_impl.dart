import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/data/datasources/duel_firestore_datasource.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';

/// Duel Repository Implementation
///
/// Implements [DuelRepository] interface using Firestore data source.
/// Handles DTO ↔ Entity mapping and exception handling.
class DuelRepositoryImpl implements DuelRepository {
  final DuelFirestoreDataSource _dataSource;

  const DuelRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, Duel>> createDuel({
    required String challengerId,
    required String challengedId,
  }) async {
    try {
      // TODO: Fetch user data from UserRepository when available
      // For now, use placeholder names (will be updated when duel is accepted)
      final duelDto = await _dataSource.createDuel(
        challengerId: challengerId,
        challengedId: challengedId,
        challengerName: 'User', // Placeholder
        challengedName: 'User', // Placeholder
        challengerPhotoUrl: null,
        challengedPhotoUrl: null,
      );

      return Right(duelDto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create duel: $e'));
    }
  }

  @override
  Future<Either<Failure, Duel>> acceptDuel(String duelId) async {
    try {
      final duelDto = await _dataSource.acceptDuel(duelId);
      return Right(duelDto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to accept duel: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelDuel(String duelId) async {
    try {
      await _dataSource.cancelDuel(duelId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to cancel duel: $e'));
    }
  }

  @override
  Future<Either<Failure, Duel>> getDuelById(String duelId) async {
    try {
      final duelDto = await _dataSource.getDuelById(duelId);
      return Right(duelDto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get duel: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Duel>>> getActiveDuels(String userId) async {
    try {
      final duelDtos = await _dataSource.getActiveDuels(userId);
      final duels = duelDtos.map((dto) => dto.toEntity()).toList();
      return Right(duels);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get active duels: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Duel>>> getPendingDuels(String userId) async {
    try {
      final duelDtos = await _dataSource.getPendingDuels(userId);
      final duels = duelDtos.map((dto) => dto.toEntity()).toList();
      return Right(duels);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get pending duels: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Duel>>> getDuelHistory(String userId) async {
    try {
      final duelDtos = await _dataSource.getDuelHistory(userId);
      final duels = duelDtos.map((dto) => dto.toEntity()).toList();
      return Right(duels);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get duel history: $e'));
    }
  }

  @override
  Future<Either<Failure, Duel?>> getActiveDuelBetween(
    String userId1,
    String userId2,
  ) async {
    try {
      final duelDto = await _dataSource.getActiveDuelBetween(userId1, userId2);
      return Right(duelDto?.toEntity());
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to check active duel: $e'));
    }
  }

  @override
  Future<Either<Failure, Duel>> updateStepCount({
    required String duelId,
    required String userId,
    required StepCount steps,
  }) async {
    try {
      final duelDto = await _dataSource.updateStepCount(
        duelId: duelId,
        userId: userId,
        steps: steps.value,
      );
      return Right(duelDto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update step count: $e'));
    }
  }

  @override
  Stream<Either<Failure, Duel>> watchDuel(String duelId) {
    try {
      return _dataSource.watchDuel(duelId).map((duelDto) {
        return Right<Failure, Duel>(duelDto.toEntity());
      }).handleError((error) {
        return Left<Failure, Duel>(
          ServerFailure(message: 'Failed to watch duel: $error'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(message: 'Failed to watch duel: $e')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<Duel>>> watchActiveDuels(String userId) {
    try {
      return _dataSource.watchActiveDuels(userId).map((duelDtos) {
        final duels = duelDtos.map((dto) => dto.toEntity()).toList();
        return Right<Failure, List<Duel>>(duels);
      }).handleError((error) {
        return Left<Failure, List<Duel>>(
          ServerFailure(message: 'Failed to watch active duels: $error'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(message: 'Failed to watch active duels: $e')),
      );
    }
  }
}
