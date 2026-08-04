import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/usecases/enqueue_offline_action.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockOfflineQueueRepository mockRepository;
  late EnqueueOfflineAction enqueueOfflineAction;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockOfflineQueueRepository();
    enqueueOfflineAction = EnqueueOfflineAction(mockRepository);
  });

  group('EnqueueOfflineAction', () {
    test('builds a QueuedAction and delegates to the repository', () async {
      when(() => mockRepository.enqueue(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await enqueueOfflineAction(
        type: OfflineActionType.acceptDuel,
        payload: const {'duelId': 'duel-1'},
        dedupKey: 'duel_duel-1',
      );

      expect(result, const Right<Failure, void>(null));
      final captured =
          verify(() => mockRepository.enqueue(captureAny())).captured;
      final action = captured.single as QueuedAction;
      expect(action.type, OfflineActionType.acceptDuel);
      expect(action.payload, const {'duelId': 'duel-1'});
      expect(action.dedupKey, 'duel_duel-1');
      expect(action.attemptCount, 0);
    });

    test('propagates repository failure', () async {
      const failure = CacheFailure(message: 'box closed');
      when(() => mockRepository.enqueue(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await enqueueOfflineAction(
        type: OfflineActionType.declineDuel,
        payload: const {'duelId': 'duel-1'},
        dedupKey: 'duel_duel-1',
      );

      expect(result, const Left<Failure, void>(failure));
    });
  });
}
