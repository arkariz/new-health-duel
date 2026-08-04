import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/features/duel/domain/offline_executors/duel_offline_executors.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerFallbackValues);

  group('AcceptDuelExecutor', () {
    late MockAcceptDuel mockAcceptDuel;
    late AcceptDuelExecutor executor;

    setUp(() {
      mockAcceptDuel = MockAcceptDuel();
      executor = AcceptDuelExecutor(mockAcceptDuel);
    });

    test('type is acceptDuel', () {
      expect(executor.type, OfflineActionType.acceptDuel);
    });

    test('execute calls AcceptDuel with duelId from payload', () async {
      mockAcceptDuel.setupSuccess(tDuelId, tActiveDuel);

      final result = await executor.execute({'duelId': tDuelId});

      expect(result, const Right<Failure, void>(null));
      verify(() => mockAcceptDuel(tDuelId)).called(1);
    });

    test('execute propagates failure', () async {
      const failure = ValidationFailure(message: 'expired');
      mockAcceptDuel.setupFailure(tDuelId, failure);

      final result = await executor.execute({'duelId': tDuelId});

      expect(result, const Left<Failure, void>(failure));
    });
  });

  group('DeclineDuelExecutor', () {
    late MockDeclineDuel mockDeclineDuel;
    late DeclineDuelExecutor executor;

    setUp(() {
      mockDeclineDuel = MockDeclineDuel();
      executor = DeclineDuelExecutor(mockDeclineDuel);
    });

    test('type is declineDuel', () {
      expect(executor.type, OfflineActionType.declineDuel);
    });

    test('execute calls DeclineDuel with duelId from payload', () async {
      mockDeclineDuel.setupSuccess(tDuelId);

      final result = await executor.execute({'duelId': tDuelId});

      expect(result, const Right<Failure, void>(null));
      verify(() => mockDeclineDuel(tDuelId)).called(1);
    });
  });

  group('CreateDuelExecutor', () {
    late MockCreateDuel mockCreateDuel;
    late CreateDuelExecutor executor;

    setUp(() {
      mockCreateDuel = MockCreateDuel();
      executor = CreateDuelExecutor(mockCreateDuel);
    });

    test('type is createDuel', () {
      expect(executor.type, OfflineActionType.createDuel);
    });

    test('execute calls CreateDuel with payload fields', () async {
      mockCreateDuel.setupSuccess(
        challengerId: 'c1',
        challengedId: 'c2',
        challengerName: 'Challenger',
        challengedName: 'Challenged',
        result: tPendingDuel,
      );

      final result = await executor.execute({
        'challengerId': 'c1',
        'challengedId': 'c2',
        'challengerName': 'Challenger',
        'challengedName': 'Challenged',
      });

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockCreateDuel(
          challengerId: 'c1',
          challengedId: 'c2',
          challengerName: 'Challenger',
          challengedName: 'Challenged',
        ),
      ).called(1);
    });

    test('conflictMessage includes the challenged name', () {
      final message = executor.conflictMessage({'challengedName': 'Bob'});
      expect(message, contains('Bob'));
    });
  });

  group('SyncStepCountExecutor', () {
    late MockSyncHealthData mockSyncHealthData;
    late SyncStepCountExecutor executor;

    setUp(() {
      mockSyncHealthData = MockSyncHealthData();
      executor = SyncStepCountExecutor(mockSyncHealthData);
    });

    test('type is syncStepCount', () {
      expect(executor.type, OfflineActionType.syncStepCount);
    });

    test('execute calls SyncHealthData with duelId and userId from payload',
        () async {
      mockSyncHealthData.setupSuccess(
        duelId: tDuelId,
        userId: 'user-1',
        result: tActiveDuel,
      );

      final result = await executor.execute({
        'duelId': tDuelId,
        'userId': 'user-1',
      });

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockSyncHealthData(duelId: tDuelId, userId: 'user-1'),
      ).called(1);
    });
  });
}
