import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/usecases/get_active_duels.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late GetActiveDuels getActiveDuels;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    getActiveDuels = GetActiveDuels(mockRepository);
  });

  group('GetActiveDuels', () {
    const userId = 'test-user-123';

    test('returns list of active duels for user', () async {
      final activeDuel = tActiveDuel;
      mockRepository.setupGetActiveDuels(userId, [activeDuel]);

      final result = await getActiveDuels(userId);

      expect(result, Right([activeDuel]));
    });

    test('returns empty list when user has no active duels', () async {
      mockRepository.setupGetActiveDuels(userId, []);

      final result = await getActiveDuels(userId);

      expect(result, const Right(<dynamic>[]));
    });

    test('propagates Failure from repository', () async {
      const failure = ServerFailure(message: 'Failed to get active duels');
      mockRepository.setupGetActiveDuelsFailure(userId, failure);

      final result = await getActiveDuels(userId);

      expect(result, const Left(failure));
    });
  });
}
