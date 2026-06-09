import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/update_step_count.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart' as duel;
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late UpdateStepCount updateStepCount;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    updateStepCount = UpdateStepCount(mockRepository);
  });

  group('UpdateStepCount', () {
    const userId = 'test-user-123';
    final steps = duel.StepCount(3000);

    group('validation', () {
      test('returns ValidationFailure when duel is not active', () async {
        final pendingDuel = tPendingDuel;
        mockRepository.setupGetDuelById(tPendingDuelId, pendingDuel);

        final result = await updateStepCount(
          duelId: tPendingDuelId,
          userId: userId,
          steps: steps,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('non-active'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(
          () => mockRepository.updateStepCount(
            duelId: any(named: 'duelId'),
            userId: any(named: 'userId'),
            steps: any(named: 'steps'),
          ),
        );
      });

      test('returns ValidationFailure when user is not a participant', () async {
        final activeDuel = tActiveDuel;
        mockRepository.setupGetDuelById(tDuelId, activeDuel);

        final result = await updateStepCount(
          duelId: tDuelId,
          userId: 'unrelated-user-id',
          steps: steps,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('not a participant'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(
          () => mockRepository.updateStepCount(
            duelId: any(named: 'duelId'),
            userId: any(named: 'userId'),
            steps: any(named: 'steps'),
          ),
        );
      });
    });

    group('success', () {
      test('updates step count for a valid participant in an active duel',
          () async {
        final activeDuel = tActiveDuel;
        mockRepository
          ..setupGetDuelById(tDuelId, activeDuel)
          ..setupUpdateStepCount(
            duelId: tDuelId,
            userId: userId,
            steps: steps,
            result: activeDuel,
          );

        final result = await updateStepCount(
          duelId: tDuelId,
          userId: userId,
          steps: steps,
        );

        expect(result, Right<Failure, Duel>(activeDuel));
      });
    });

    group('failure', () {
      test('propagates failure from getDuelById', () async {
        const failure = ServerFailure(message: 'Duel not found');
        mockRepository.setupGetDuelByIdFailure(tDuelId, failure);

        final result = await updateStepCount(
          duelId: tDuelId,
          userId: userId,
          steps: steps,
        );

        expect(result, const Left<Failure, Duel>(failure));
      });

      test('propagates failure from repository updateStepCount', () async {
        const failure = ServerFailure(message: 'Write failed');
        mockRepository
          ..setupGetDuelById(tDuelId, tActiveDuel)
          ..setupUpdateStepCountFailure(
            duelId: tDuelId,
            userId: userId,
            steps: steps,
            failure: failure,
          );

        final result = await updateStepCount(
          duelId: tDuelId,
          userId: userId,
          steps: steps,
        );

        expect(result, const Left<Failure, Duel>(failure));
      });
    });
  });
}
