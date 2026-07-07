import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/complete_duel.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late CompleteDuel completeDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    completeDuel = CompleteDuel(mockRepository);
  });

  group('CompleteDuel', () {
    test('delegates to repository and returns completed duel', () async {
      final completedDuel = tJustCompletedDuel;
      when(() => mockRepository.completeDuel(tDuelId))
          .thenAnswer((_) async => Right(completedDuel));

      final result = await completeDuel(tDuelId);

      expect(result, Right<Failure, Duel>(completedDuel));
      verify(() => mockRepository.completeDuel(tDuelId)).called(1);
    });

    test('propagates ServerFailure from repository', () async {
      const failure = ServerFailure(message: 'Failed to complete duel');
      when(() => mockRepository.completeDuel(tDuelId))
          .thenAnswer((_) async => const Left(failure));

      final result = await completeDuel(tDuelId);

      expect(result, const Left<Failure, Duel>(failure));
    });

    test('propagates ValidationFailure from repository', () async {
      const failure = ValidationFailure(message: 'Duel has not ended yet');
      when(() => mockRepository.completeDuel(tDuelId))
          .thenAnswer((_) async => const Left(failure));

      final result = await completeDuel(tDuelId);

      expect(result, const Left<Failure, Duel>(failure));
    });
  });
}
