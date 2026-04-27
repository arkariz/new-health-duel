import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/usecases/get_duel_history.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late GetDuelHistory getDuelHistory;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    getDuelHistory = GetDuelHistory(mockRepository);
  });

  group('GetDuelHistory', () {
    const userId = 'test-user-123';

    test('returns completed duels for user', () async {
      mockRepository.setupGetDuelHistory(userId, [tCompletedDuel]);

      final result = await getDuelHistory(userId);

      expect(result, Right([tCompletedDuel]));
    });

    test('returns empty list when user has no duel history', () async {
      mockRepository.setupGetDuelHistory(userId, []);

      final result = await getDuelHistory(userId);

      expect(result, const Right(<dynamic>[]));
    });

    test('propagates Failure from repository', () async {
      const failure = ServerFailure(message: 'Failed to get duel history');
      mockRepository.setupGetDuelHistoryFailure(userId, failure);

      final result = await getDuelHistory(userId);

      expect(result, const Left(failure));
    });
  });
}
