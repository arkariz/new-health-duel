import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/usecases/create_duel.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelRepository mockRepository;
  late CreateDuel createDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockDuelRepository();
    createDuel = CreateDuel(mockRepository);
  });

  group('CreateDuel', () {
    const challengerId = 'test-user-123';
    const challengedId = 'opponent-user-456';
    const challengerName = 'Test User';
    const challengedName = 'Opponent User';

    group('validation', () {
      test('returns ValidationFailure when challenger equals challenged', () async {
        final result = await createDuel(
          challengerId: challengerId,
          challengedId: challengerId,
          challengerName: challengerName,
          challengedName: challengerName,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Cannot challenge yourself'));
          },
          (_) => fail('Expected a failure'),
        );
      });

      test('returns ValidationFailure when active duel already exists', () async {
        mockRepository.setupGetActiveDuelBetween(
          challengerId,
          challengedId,
          tActiveDuel,
        );

        final result = await createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
          challengerName: challengerName,
          challengedName: challengedName,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('already have an active duel'));
          },
          (_) => fail('Expected a failure'),
        );
      });
    });

    group('success', () {
      test('creates duel when no active duel exists between users', () async {
        final expectedDuel = tPendingDuel;
        mockRepository
          ..setupGetActiveDuelBetween(
            challengerId,
            challengedId,
            null,
          )
          ..setupCreateDuel(
            challengerId: challengerId,
            challengedId: challengedId,
            challengerName: challengerName,
            challengedName: challengedName,
            duel: expectedDuel,
          );

        final result = await createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
          challengerName: challengerName,
          challengedName: challengedName,
        );

        expect(result, Right<Failure, Duel>(expectedDuel));
      });

      test('proceeds when getActiveDuelBetween returns Left (error)', () async {
        final expectedDuel = tPendingDuel;
        mockRepository
          ..setupGetActiveDuelBetweenFailure(
            challengerId,
            challengedId,
            const ServerFailure(message: 'Firestore unavailable'),
          )
          ..setupCreateDuel(
            challengerId: challengerId,
            challengedId: challengedId,
            challengerName: challengerName,
            challengedName: challengedName,
            duel: expectedDuel,
          );

        final result = await createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
          challengerName: challengerName,
          challengedName: challengedName,
        );

        expect(result, Right<Failure, Duel>(expectedDuel));
      });
    });

    group('failure', () {
      test('propagates ServerFailure from createDuel repository call', () async {
        const failure = ServerFailure(message: 'Failed to create duel: network error');

        mockRepository
          ..setupGetActiveDuelBetween(challengerId, challengedId, null)
          ..setupCreateDuelFailure(
            challengerId: challengerId,
            challengedId: challengedId,
            challengerName: challengerName,
            challengedName: challengedName,
            failure: failure,
          );

        final result = await createDuel(
          challengerId: challengerId,
          challengedId: challengedId,
          challengerName: challengerName,
          challengedName: challengedName,
        );

        expect(result, const Left<Failure, Duel>(failure));
      });
    });
  });
}
