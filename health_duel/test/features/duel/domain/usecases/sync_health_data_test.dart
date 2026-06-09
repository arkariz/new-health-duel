import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/sync_health_data.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockDuelRepository;
  late MockHealthRepository mockHealthRepository;
  late SyncHealthData syncHealthData;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockDuelRepository = MockDuelRepository();
    mockHealthRepository = MockHealthRepository();
    syncHealthData = SyncHealthData(mockHealthRepository, mockDuelRepository);
  });

  group('SyncHealthData', () {
    const userId = 'test-user-123';
    const steps = 2500; // same value as tSyncedSteps

    group('validation', () {
      test('returns ValidationFailure when duel is not active', () async {
        final pendingDuel = tPendingDuel;
        mockDuelRepository.setupGetDuelById(tPendingDuelId, pendingDuel);

        final result = await syncHealthData(
          duelId: tPendingDuelId,
          userId: userId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('not active'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(() => mockHealthRepository.getStepCount(
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            ));
      });
    });

    group('success', () {
      test('fetches steps from health and updates duel step count', () async {
        final activeDuel = tActiveDuel;
        mockDuelRepository.setupGetDuelById(tDuelId, activeDuel);
        when(
          () => mockHealthRepository.getStepCount(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).thenAnswer((_) async => Right(tStepDataRaw()));
        mockDuelRepository.setupUpdateStepCount(
          duelId: tDuelId,
          userId: userId,
          steps: duel.StepCount(steps),
          result: activeDuel,
        );

        final result = await syncHealthData(duelId: tDuelId, userId: userId);

        expect(result, Right<Failure, Duel>(activeDuel));
      });
    });

    group('failure', () {
      test('propagates failure from getDuelById', () async {
        const failure = ServerFailure(message: 'Duel not found');
        mockDuelRepository.setupGetDuelByIdFailure(tDuelId, failure);

        final result = await syncHealthData(duelId: tDuelId, userId: userId);

        expect(result, const Left<Failure, Duel>(failure));
        verifyNever(() => mockHealthRepository.getStepCount(
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            ));
      });

      test('propagates failure from health repository getStepCount', () async {
        const failure = NetworkFailure(message: 'Health Connect unavailable');
        mockDuelRepository.setupGetDuelById(tDuelId, tActiveDuel);
        when(
          () => mockHealthRepository.getStepCount(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        final result = await syncHealthData(duelId: tDuelId, userId: userId);

        expect(result, const Left<Failure, Duel>(failure));
      });

      test('propagates failure from updateStepCount', () async {
        const failure = ServerFailure(message: 'Failed to update steps');
        mockDuelRepository.setupGetDuelById(tDuelId, tActiveDuel);
        when(
          () => mockHealthRepository.getStepCount(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).thenAnswer((_) async => Right(tStepDataRaw()));
        mockDuelRepository.setupUpdateStepCountFailure(
          duelId: tDuelId,
          userId: userId,
          steps: duel.StepCount(steps),
          failure: failure,
        );

        final result = await syncHealthData(duelId: tDuelId, userId: userId);

        expect(result, const Left<Failure, Duel>(failure));
      });
    });
  });
}
