import 'package:dartz/dartz.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/exception_mapper.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/data/datasources/offline_queue_local_datasource.dart';
import 'package:health_duel/core/offline_queue/data/models/queued_action_model.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';

class OfflineQueueRepositoryImpl implements OfflineQueueRepository {
  const OfflineQueueRepositoryImpl(this._dataSource);

  final OfflineQueueLocalDataSource _dataSource;

  @override
  Future<Either<Failure, void>> enqueue(QueuedAction action) async {
    try {
      // Dedup-replace: an existing entry with the same dedupKey (including
      // a cross-canceling accept↔decline on the same duel) is removed
      // before the new one is written.
      await _dataSource.removeByDedupKey(action.dedupKey);
      await _dataSource.put(QueuedActionModel.fromEntity(action));
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to queue offline action',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String id) async {
    try {
      await _dataSource.remove(id);
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to remove offline action',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> update(QueuedAction action) async {
    try {
      await _dataSource.update(QueuedActionModel.fromEntity(action));
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to update offline action',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<QueuedAction>>> getAll() async {
    try {
      final models = await _dataSource.getAll();
      final entities = models
          .map((model) => model.toEntity())
          .whereType<QueuedAction>()
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(entities);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to read offline queue',
        originalException: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clear() async {
    try {
      await _dataSource.clear();
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: 'Failed to clear offline queue',
        originalException: e.toString(),
      ));
    }
  }
}
