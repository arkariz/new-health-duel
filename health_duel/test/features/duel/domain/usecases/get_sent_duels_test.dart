import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/get_sent_duels.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late GetSentDuels getSentDuels;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    getSentDuels = GetSentDuels(mockRepository);
  });

  group('GetSentDuels', () {
    const userId = 'test-user-123';

    test('returns list of outgoing pending duel challenges for user', () async {
      final sentDuel = tSentDuel;
      mockRepository.setupGetSentDuels(userId, [sentDuel]);

      final result = await getSentDuels(userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (duels) {
          expect(duels, hasLength(1));
          expect(duels.first.id, sentDuel.id);
        },
      );
    });

    test('returns empty list when user has no sent duels', () async {
      mockRepository.setupGetSentDuels(userId, []);

      final result = await getSentDuels(userId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (duels) => expect(duels, isEmpty),
      );
    });

    test('propagates Failure from repository', () async {
      const failure = ServerFailure(message: 'Failed to get sent duels');
      mockRepository.setupGetSentDuelsFailure(userId, failure);

      final result = await getSentDuels(userId);

      expect(result, const Left<Failure, List<Duel>>(failure));
    });
  });
}
