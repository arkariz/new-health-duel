import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/presentation/offline_aware_action.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockConnectivityCubit mockConnectivityCubit;
  late MockEnqueueOfflineAction mockEnqueueOfflineAction;
  late OfflineAwareAction offlineAwareAction;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockConnectivityCubit = MockConnectivityCubit();
    mockEnqueueOfflineAction = MockEnqueueOfflineAction();
    offlineAwareAction =
        OfflineAwareAction(mockConnectivityCubit, mockEnqueueOfflineAction);
  });

  group('OfflineAwareAction', () {
    test('runs online callback and returns its result when online', () async {
      when(() => mockConnectivityCubit.isOffline).thenReturn(false);
      var onlineCalled = false;

      final result = await offlineAwareAction.runOrQueue<String>(
        online: () async {
          onlineCalled = true;
          return const Right('done');
        },
        type: OfflineActionType.acceptDuel,
        payload: const {'duelId': 'd1'},
        dedupKey: 'duel_d1',
      );

      expect(onlineCalled, isTrue);
      expect(result, const Right<Failure, String>('done'));
      verifyNever(
        () => mockEnqueueOfflineAction(
          type: any(named: 'type'),
          payload: any(named: 'payload'),
          dedupKey: any(named: 'dedupKey'),
        ),
      );
    });

    test('enqueues and returns null instead of calling online when offline',
        () async {
      when(() => mockConnectivityCubit.isOffline).thenReturn(true);
      when(
        () => mockEnqueueOfflineAction(
          type: any(named: 'type'),
          payload: any(named: 'payload'),
          dedupKey: any(named: 'dedupKey'),
        ),
      ).thenAnswer((_) async => const Right(null));
      var onlineCalled = false;

      final result = await offlineAwareAction.runOrQueue<String>(
        online: () async {
          onlineCalled = true;
          return const Right('done');
        },
        type: OfflineActionType.declineDuel,
        payload: const {'duelId': 'd1'},
        dedupKey: 'duel_d1',
      );

      expect(onlineCalled, isFalse);
      expect(result, isNull);
      verify(
        () => mockEnqueueOfflineAction(
          type: OfflineActionType.declineDuel,
          payload: const {'duelId': 'd1'},
          dedupKey: 'duel_d1',
        ),
      ).called(1);
    });
  });
}
