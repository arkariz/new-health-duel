import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/data/background/health_sync_background_task.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockActiveDuelPointer mockPointer;
  late MockSyncHealthData mockSyncHealthData;
  var firebaseInitCalls = 0;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockPointer = MockActiveDuelPointer();
    mockSyncHealthData = MockSyncHealthData();
    firebaseInitCalls = 0;
  });

  HealthSyncBackgroundHandler buildHandler() => HealthSyncBackgroundHandler(
        firebaseInit: () async => firebaseInitCalls++,
        pointer: mockPointer,
        syncHealthData: mockSyncHealthData,
      );

  group('HealthSyncBackgroundHandler', () {
    test('does nothing when there is no active duel pointer', () async {
      when(() => mockPointer.read()).thenAnswer((_) async => null);

      await buildHandler().run();

      expect(firebaseInitCalls, 1);
      verifyNever(
        () => mockSyncHealthData(
          duelId: any(named: 'duelId'),
          userId: any(named: 'userId'),
        ),
      );
    });

    test('syncs the pointed-to duel when a pointer exists', () async {
      when(() => mockPointer.read()).thenAnswer(
        (_) async => (duelId: tDuelId, userId: 'test-user-123'),
      );
      when(
        () => mockSyncHealthData(
          duelId: tDuelId,
          userId: 'test-user-123',
        ),
      ).thenAnswer((_) async => Right(tActiveDuel));

      await buildHandler().run();

      verify(
        () => mockSyncHealthData(duelId: tDuelId, userId: 'test-user-123'),
      ).called(1);
    });

    test('does not throw when sync fails', () async {
      when(() => mockPointer.read()).thenAnswer(
        (_) async => (duelId: tDuelId, userId: 'test-user-123'),
      );
      when(
        () => mockSyncHealthData(
          duelId: tDuelId,
          userId: 'test-user-123',
        ),
      ).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'offline')),
      );

      await expectLater(buildHandler().run(), completes);
    });
  });
}
