import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/usecases/decline_duel.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late DeclineDuel declineDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    declineDuel = DeclineDuel(mockRepository);
  });

  group('DeclineDuel', () {
    group('validation', () {
      test('returns ValidationFailure when duel is already active', () async {
        mockRepository.setupGetDuelById(tDuelId, tActiveDuel);

        final result = await declineDuel(tDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('cannot be declined'));
          },
          (_) => fail('Expected a failure'),
        );
        verifyNever(() => mockRepository.cancelDuel(any()));
      });

      test('returns ValidationFailure when duel is completed', () async {
        mockRepository.setupGetDuelById(tHistoryDuelId, tCompletedDuel);

        final result = await declineDuel(tHistoryDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected a failure'),
        );
        verifyNever(() => mockRepository.cancelDuel(any()));
      });
    });

    group('success', () {
      test('cancels a valid pending duel and returns void', () async {
        final pendingDuel = tPendingDuel;
        mockRepository.setupGetDuelById(tPendingDuelId, pendingDuel);
        mockRepository.setupCancelDuel(tPendingDuelId);

        final result = await declineDuel(tPendingDuelId);

        expect(result, const Right(null));
      });
    });

    group('failure', () {
      test('propagates failure from getDuelById', () async {
        const failure = ServerFailure(message: 'Duel not found');
        mockRepository.setupGetDuelByIdFailure(tDuelId, failure);

        final result = await declineDuel(tDuelId);

        expect(result, const Left(failure));
        verifyNever(() => mockRepository.cancelDuel(any()));
      });

      test('propagates failure from cancelDuel repository call', () async {
        const failure = ServerFailure(message: 'Failed to cancel duel');
        mockRepository.setupGetDuelById(tPendingDuelId, tPendingDuel);
        mockRepository.setupCancelDuelFailure(tPendingDuelId, failure);

        final result = await declineDuel(tPendingDuelId);

        expect(result, const Left(failure));
      });
    });
  });
}
