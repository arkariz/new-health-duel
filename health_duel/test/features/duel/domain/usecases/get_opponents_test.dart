import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/data.dart';
import 'package:health_duel/features/duel/domain/usecases/get_opponents.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late GetOpponents getOpponents;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    getOpponents = GetOpponents(mockRepository);
  });

  group('GetOpponents', () {
    const currentUserId = 'test-user-123';

    test('returns list of potential opponents excluding current user', () async {
      final opponents = [tOpponentModel, tOpponent2Model];
      mockRepository.setupGetOpponents(currentUserId, opponents);

      final result = await getOpponents(currentUserId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (users) {
          expect(users, hasLength(2));
          expect(users.first.id, tOpponentModel.id);
        },
      );
    });

    test('returns empty list when no other users exist', () async {
      mockRepository.setupGetOpponents(currentUserId, []);

      final result = await getOpponents(currentUserId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (users) => expect(users, isEmpty),
      );
    });

    test('propagates Failure from repository', () async {
      const failure = ServerFailure(message: 'Failed to get opponents');
      mockRepository.setupGetOpponentsFailure(currentUserId, failure);

      final result = await getOpponents(currentUserId);

      expect(result, const Left<Failure, List<UserModel>>(failure));
    });
  });
}
