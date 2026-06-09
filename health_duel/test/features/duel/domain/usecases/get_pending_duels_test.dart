import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/get_pending_duels.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late GetPendingDuels getPendingDuels;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    getPendingDuels = GetPendingDuels(mockRepository);
  });

  group('GetPendingDuels', () {
    const userId = 'test-user-123';

    test('returns list of pending duel invitations for user', () async {
      final pendingDuel = tPendingDuel;
      mockRepository.setupGetPendingDuels(userId, [pendingDuel]);

      final result = await getPendingDuels(userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (duels) {
          expect(duels, hasLength(1));
          expect(duels.first.id, pendingDuel.id);
        },
      );
    });

    test('returns empty list when user has no pending duels', () async {
      mockRepository.setupGetPendingDuels(userId, []);

      final result = await getPendingDuels(userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (duels) => expect(duels, isEmpty),
      );
    });

    test('propagates Failure from repository', () async {
      const failure = ServerFailure(message: 'Failed to get pending duels');
      mockRepository.setupGetPendingDuelsFailure(userId, failure);

      final result = await getPendingDuels(userId);

      expect(result, const Left<Failure, List<Duel>>(failure));
    });
  });
}
