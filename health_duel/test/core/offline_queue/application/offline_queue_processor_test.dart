import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/application/offline_queue_processor.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/executor/offline_action_executor.dart';
import 'package:health_duel/core/offline_queue/domain/notification/offline_queue_notification.dart';
import 'package:health_duel/core/offline_queue/domain/repositories/offline_queue_repository.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';

/// Simple in-memory fake — no mocktail scripting needed for straightforward
/// CRUD semantics, keeps the processor tests focused on drain/backoff logic.
class _FakeOfflineQueueRepository implements OfflineQueueRepository {
  final Map<String, QueuedAction> store = {};

  @override
  Future<Either<Failure, void>> enqueue(QueuedAction action) async {
    store.removeWhere((_, a) => a.dedupKey == action.dedupKey);
    store[action.id] = action;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> remove(String id) async {
    store.remove(id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> update(QueuedAction action) async {
    store[action.id] = action;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<QueuedAction>>> getAll() async {
    final list = store.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Right(list);
  }

  @override
  Future<Either<Failure, void>> clear() async {
    store.clear();
    return const Right(null);
  }
}

class _FakeExecutor implements OfflineActionExecutor {
  _FakeExecutor(
    this.type,
    this._handler, {
    this.conflictMsg = 'conflict',
  });

  @override
  final OfflineActionType type;
  final Future<Either<Failure, void>> Function(Map<String, dynamic>) _handler;
  final String conflictMsg;
  int callCount = 0;

  @override
  Future<Either<Failure, void>> execute(Map<String, dynamic> payload) {
    callCount++;
    return _handler(payload);
  }

  @override
  String conflictMessage(Map<String, dynamic> payload) => conflictMsg;
}

QueuedAction _action({
  String id = 'a1',
  OfflineActionType type = OfflineActionType.acceptDuel,
  String dedupKey = 'duel_1',
  DateTime? createdAt,
}) =>
    QueuedAction(
      id: id,
      type: type,
      payload: const {'duelId': 'duel-1'},
      dedupKey: dedupKey,
      createdAt: createdAt ?? DateTime(2026),
    );

void main() {
  group('OfflineQueueProcessor', () {
    late _FakeOfflineQueueRepository repository;
    late StreamController<ConnectivityStatus> connectivityController;
    late bool online;
    late List<Duration> waitedDurations;

    OfflineQueueProcessor buildProcessor({
      Duration executeTimeout = const Duration(seconds: 20),
      int maxAttempts = 6,
    }) {
      return OfflineQueueProcessor(
        repository: repository,
        connectivityStream: connectivityController.stream,
        isOnline: () => online,
        wait: (duration) async {
          waitedDurations.add(duration);
        },
        executeTimeout: executeTimeout,
        maxAttempts: maxAttempts,
      );
    }

    setUp(() {
      repository = _FakeOfflineQueueRepository();
      connectivityController = StreamController<ConnectivityStatus>.broadcast();
      online = false;
      waitedDurations = [];
    });

    tearDown(() async {
      await connectivityController.close();
    });

    test('drains immediately when already online at start()', () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Right(null),
      );
      final processor = buildProcessor()..registerExecutor(executor);

      final notifications = <OfflineQueueNotification>[];
      processor.notifications.listen(notifications.add);

      await processor.start();
      await Future<void>.delayed(Duration.zero);

      expect(executor.callCount, 1);
      expect(repository.store, isEmpty);
      expect(notifications, [const DrainSucceeded(synced: 1, pending: 0)]);
    });

    test('drains on offline→online connectivity transition', () async {
      online = false;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Right(null),
      );
      final processor = buildProcessor()..registerExecutor(executor);
      await processor.start();
      await Future<void>.delayed(Duration.zero);

      expect(executor.callCount, 0); // still offline, nothing drained yet

      online = true;
      connectivityController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(executor.callCount, 1);
      expect(repository.store, isEmpty);
    });

    test('ValidationFailure drops the action and emits ActionConflicted', () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Left(ValidationFailure(message: 'expired')),
        conflictMsg: 'This duel invitation is no longer available.',
      );
      final processor = buildProcessor()..registerExecutor(executor);

      final notifications = <OfflineQueueNotification>[];
      processor.notifications.listen(notifications.add);

      await processor.start();
      await Future<void>.delayed(Duration.zero);

      expect(repository.store, isEmpty);
      expect(
        notifications,
        [
          const ActionConflicted('This duel invitation is no longer available.'),
          const PendingChanged(0),
        ],
      );
    });

    test('retries with exponential backoff until maxAttempts, then drops',
        () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Left(ServerFailure(message: 'down')),
      );
      final processor = buildProcessor(maxAttempts: 3)
        ..registerExecutor(executor);

      final notifications = <OfflineQueueNotification>[];
      processor.notifications.listen(notifications.add);

      await processor.start();
      await Future<void>.delayed(Duration.zero);

      expect(executor.callCount, 3);
      expect(repository.store, isEmpty);
      expect(waitedDurations, [
        const Duration(seconds: 2),
        const Duration(seconds: 4),
      ]);
      expect(notifications, [
        const ActionDropped(OfflineActionType.acceptDuel),
        const PendingChanged(0),
      ]);
    });

    test('caps backoff at 60 seconds', () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Left(ServerFailure(message: 'down')),
      );
      final processor = buildProcessor(maxAttempts: 8)
        ..registerExecutor(executor);

      await processor.start();
      await Future<void>.delayed(Duration.zero);

      // 2,4,8,16,32,60,60 (7 waits for 8 attempts before drop)
      expect(waitedDurations.last, const Duration(seconds: 60));
    });

    test('a timeout is treated as retryable, not a conflict', () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) => Completer<Either<Failure, void>>().future, // never completes
      );
      final processor = buildProcessor(
        executeTimeout: const Duration(milliseconds: 1),
        maxAttempts: 1,
      )..registerExecutor(executor);

      final notifications = <OfflineQueueNotification>[];
      processor.notifications.listen(notifications.add);

      await processor.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // maxAttempts=1 means the first (timed-out) attempt already trips the
      // drop threshold — dropped, not conflicted.
      expect(repository.store, isEmpty);
      expect(notifications, [
        const ActionDropped(OfflineActionType.acceptDuel),
        const PendingChanged(0),
      ]);
    });

    test('aborts mid-drain when connectivity drops between actions', () async {
      online = true;
      await repository.enqueue(_action(id: 'a1', dedupKey: 'duel_1'));
      await repository.enqueue(_action(
        id: 'a2',
        dedupKey: 'duel_2',
        createdAt: DateTime(2026, 1, 1, 0, 0, 1),
      ));
      final executor = _FakeExecutor(OfflineActionType.acceptDuel, (_) async {
        online = false; // go offline after the first action executes
        return const Right(null);
      });
      final processor = buildProcessor()..registerExecutor(executor);

      await processor.start();
      await Future<void>.delayed(Duration.zero);

      expect(executor.callCount, 1);
      expect(repository.store.length, 1); // second action left untouched
    });

    test('concurrent drain() calls are collapsed (re-entrancy guard)',
        () async {
      online = true;
      await repository.enqueue(_action());
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return const Right(null);
        },
      );
      final processor = buildProcessor()..registerExecutor(executor);

      await Future.wait([processor.drain(), processor.drain(), processor.drain()]);

      expect(executor.callCount, 1);
    });

    test('registerExecutor throws on duplicate registration for the same type',
        () {
      final processor = buildProcessor();
      final executor = _FakeExecutor(
        OfflineActionType.acceptDuel,
        (_) async => const Right(null),
      );
      processor.registerExecutor(executor);

      expect(() => processor.registerExecutor(executor), throwsStateError);
    });
  });
}
