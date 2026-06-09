import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/accept_duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late AcceptDuel acceptDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    acceptDuel = AcceptDuel(mockRepository);
  });

  group('AcceptDuel', () {
    group('validation', () {
      test('returns ValidationFailure when duel is already active', () async {
        mockRepository.setupGetDuelById(tDuelId, tActiveDuel);

        final result = await acceptDuel(tDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('cannot be accepted'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(() => mockRepository.acceptDuel(any()));
      });

      test('returns ValidationFailure when pending duel is expired', () async {
        // Create a pending duel created more than 24 hours ago
        final expiredPendingDuel = Duel(
          id: tPendingDuelId,
          challengerId: tOpponentModel.id,
          challengedId: tUserModel.id,
          challengerName: tOpponentModel.name,
          challengedName: tUserModel.name,
          challengerSteps: StepCount(0),
          challengedSteps: StepCount(0),
          status: DuelStatus.pending,
          startTime: tDuelStartTime,
          endTime: tDuelEndTime,
          createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        );

        mockRepository.setupGetDuelById(tPendingDuelId, expiredPendingDuel);

        final result = await acceptDuel(tPendingDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('expired'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(() => mockRepository.acceptDuel(any()));
      });
    });

    group('success', () {
      test('accepts a valid pending duel and returns updated duel', () async {
        final pendingDuel = tPendingDuel;
        final activeDuel = tActiveDuel;
        mockRepository
          ..setupGetDuelById(tPendingDuelId, pendingDuel)
          ..setupAcceptDuel(tPendingDuelId, activeDuel);

        final result = await acceptDuel(tPendingDuelId);

        expect(result, Right<Failure, Duel>(activeDuel));
      });
    });

    group('failure', () {
      test('propagates failure from getDuelById', () async {
        const failure = ServerFailure(message: 'Duel not found');
        mockRepository.setupGetDuelByIdFailure(tDuelId, failure);

        final result = await acceptDuel(tDuelId);

        expect(result, const Left<Failure, Duel>(failure));
        verifyNever(() => mockRepository.acceptDuel(any()));
      });

      test('propagates failure from acceptDuel repository call', () async {
        const failure = ServerFailure(message: 'Failed to accept duel');
        mockRepository
          ..setupGetDuelById(tPendingDuelId, tPendingDuel)
          ..setupAcceptDuelFailure(tPendingDuelId, failure);

        final result = await acceptDuel(tPendingDuelId);

        expect(result, const Left<Failure, Duel>(failure));
      });
    });
  });
}
