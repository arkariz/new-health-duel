import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/expire_pending_duel.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late ExpirePendingDuel expirePendingDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    expirePendingDuel = ExpirePendingDuel(mockRepository);
  });

  group('ExpirePendingDuel', () {
    test('delegates to repository and returns expired duel', () async {
      final expiredDuel = tExpiredPendingDuel;
      when(() => mockRepository.expirePendingDuel(tPendingDuelId))
          .thenAnswer((_) async => Right(expiredDuel));

      final result = await expirePendingDuel(tPendingDuelId);

      expect(result, Right<Failure, Duel>(expiredDuel));
      verify(() => mockRepository.expirePendingDuel(tPendingDuelId)).called(1);
    });

    test('propagates ServerFailure from repository', () async {
      const failure = ServerFailure(message: 'Failed to expire pending duel');
      when(() => mockRepository.expirePendingDuel(tPendingDuelId))
          .thenAnswer((_) async => const Left(failure));

      final result = await expirePendingDuel(tPendingDuelId);

      expect(result, const Left<Failure, Duel>(failure));
    });

    test('propagates ValidationFailure from repository', () async {
      const failure =
          ValidationFailure(message: 'Pending duel has not expired yet');
      when(() => mockRepository.expirePendingDuel(tPendingDuelId))
          .thenAnswer((_) async => const Left(failure));

      final result = await expirePendingDuel(tPendingDuelId);

      expect(result, const Left<Failure, Duel>(failure));
    });
  });
}
