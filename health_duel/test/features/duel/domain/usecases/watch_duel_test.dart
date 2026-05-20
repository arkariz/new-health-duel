import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/watch_duel.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late WatchDuel watchDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    watchDuel = WatchDuel(mockRepository);
  });

  group('WatchDuel', () {
    test('returns stream that emits duel updates from repository', () async {
      final activeDuel = tActiveDuel;
      mockRepository.setupWatchDuel(
        tDuelId,
        Stream.value(Right(activeDuel)),
      );

      final resultStream = watchDuel(tDuelId);

      await expectLater(resultStream, emits(Right(activeDuel)));
    });

    test('forwards errors emitted by repository stream', () async {
      const failure = ServerFailure(message: 'Real-time connection lost');
      mockRepository.setupWatchDuel(
        tDuelId,
        Stream.value(const Left(failure)),
      );

      final resultStream = watchDuel(tDuelId);

      await expectLater(resultStream, emits(const Left(failure)));
    });

    test('emits multiple sequential duel updates', () async {
      final duel1 = tActiveDuel;
      final duel2 = tCompletedDuel; // distinct duel with different steps/status
      final stream = Stream<Either<Failure, Duel>>.fromIterable([
        Right(duel1),
        Right(duel2),
      ]);
      mockRepository.setupWatchDuel(tDuelId, stream);

      final resultStream = watchDuel(tDuelId);

      await expectLater(
        resultStream,
        emitsInOrder([Right(duel1), Right(duel2)]),
      );
    });
  });
}
