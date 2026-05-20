import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/data/models/duel_dto.dart';
import 'package:health_duel/features/duel/data/repositories/duel_repository_impl.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelFirestoreDataSource mockDataSource;
  late DuelRepositoryImpl repository;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockDataSource = MockDuelFirestoreDataSource();
    repository = DuelRepositoryImpl(mockDataSource);
  });

  group('DuelRepositoryImpl', () {
    // ─── createDuel ───────────────────────────────────────────────────────────
    group('createDuel', () {
      test('returns Duel entity on success', () async {
        when(
          () => mockDataSource.createDuel(
            challengerId: any(named: 'challengerId'),
            challengedId: any(named: 'challengedId'),
            challengerName: any(named: 'challengerName'),
            challengedName: any(named: 'challengedName'),
            challengerPhotoUrl: any(named: 'challengerPhotoUrl'),
            challengedPhotoUrl: any(named: 'challengedPhotoUrl'),
          ),
        ).thenAnswer((_) async => tActiveDuelDto());

        final result = await repository.createDuel(
          challengerId: tUserModel.id,
          challengedId: tOpponentModel.id,
          challengerName: tUserModel.name,
          challengedName: tOpponentModel.name,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (duel) {
            expect(duel.challengerId, tUserModel.id);
            expect(duel.challengedId, tOpponentModel.id);
          },
        );
      });

      test('returns ServerFailure when datasource throws', () async {
        when(
          () => mockDataSource.createDuel(
            challengerId: any(named: 'challengerId'),
            challengedId: any(named: 'challengedId'),
            challengerName: any(named: 'challengerName'),
            challengedName: any(named: 'challengedName'),
            challengerPhotoUrl: any(named: 'challengerPhotoUrl'),
            challengedPhotoUrl: any(named: 'challengedPhotoUrl'),
          ),
        ).thenThrow(Exception('Firestore error'));

        final result = await repository.createDuel(
          challengerId: tUserModel.id,
          challengedId: tOpponentModel.id,
          challengerName: tUserModel.name,
          challengedName: tOpponentModel.name,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    // ─── acceptDuel ───────────────────────────────────────────────────────────
    group('acceptDuel', () {
      test('returns updated Duel entity on success', () async {
        when(() => mockDataSource.acceptDuel(tDuelId))
            .thenAnswer((_) async => tActiveDuelDto());

        final result = await repository.acceptDuel(tDuelId);

        expect(result.isRight(), isTrue);
      });

      test('returns ServerFailure when datasource throws', () async {
        when(() => mockDataSource.acceptDuel(tDuelId))
            .thenThrow(Exception('Permission denied'));

        final result = await repository.acceptDuel(tDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    // ─── cancelDuel ───────────────────────────────────────────────────────────
    group('cancelDuel', () {
      test('returns void on success', () async {
        when(() => mockDataSource.cancelDuel(tPendingDuelId))
            .thenAnswer((_) async {});

        final result = await repository.cancelDuel(tPendingDuelId);

        expect(result, const Right(null));
      });

      test('returns ServerFailure when datasource throws', () async {
        when(() => mockDataSource.cancelDuel(tPendingDuelId))
            .thenThrow(Exception('Network error'));

        final result = await repository.cancelDuel(tPendingDuelId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    // ─── getActiveDuels ───────────────────────────────────────────────────────
    group('getActiveDuels', () {
      test('maps DuelDto list to Duel entity list', () async {
        when(() => mockDataSource.getActiveDuels(tUserModel.id))
            .thenAnswer((_) async => [tActiveDuelDto()]);

        final result = await repository.getActiveDuels(tUserModel.id);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (duels) {
            expect(duels, hasLength(1));
            expect(duels.first.id, tDuelId);
          },
        );
      });

      test('returns empty list when no active duels', () async {
        when(() => mockDataSource.getActiveDuels(tUserModel.id))
            .thenAnswer((_) async => []);

        final result = await repository.getActiveDuels(tUserModel.id);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (duels) => expect(duels, isEmpty),
        );
      });

      test('returns ServerFailure when datasource throws', () async {
        when(() => mockDataSource.getActiveDuels(tUserModel.id))
            .thenThrow(Exception('Query failed'));

        final result = await repository.getActiveDuels(tUserModel.id);

        expect(result.isLeft(), isTrue);
      });
    });

    // ─── getPendingDuels ──────────────────────────────────────────────────────
    group('getPendingDuels', () {
      test('maps DuelDto list to Duel entity list', () async {
        when(() => mockDataSource.getPendingDuels(tUserModel.id))
            .thenAnswer((_) async => [tPendingDuelDto()]);

        final result = await repository.getPendingDuels(tUserModel.id);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (duels) {
            expect(duels, hasLength(1));
            expect(duels.first.id, tPendingDuelId);
          },
        );
      });

      test('returns ServerFailure when datasource throws', () async {
        when(() => mockDataSource.getPendingDuels(tUserModel.id))
            .thenThrow(Exception('Query failed'));

        final result = await repository.getPendingDuels(tUserModel.id);

        expect(result.isLeft(), isTrue);
      });
    });

    // ─── getDuelHistory ───────────────────────────────────────────────────────
    group('getDuelHistory', () {
      test('maps DuelDto list to Duel entity list', () async {
        when(() => mockDataSource.getDuelHistory(tUserModel.id))
            .thenAnswer((_) async => [tCompletedDuelDto()]);

        final result = await repository.getDuelHistory(tUserModel.id);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (duels) {
            expect(duels, hasLength(1));
            expect(duels.first.id, tHistoryDuelId);
          },
        );
      });

      test('returns ServerFailure when datasource throws', () async {
        when(() => mockDataSource.getDuelHistory(tUserModel.id))
            .thenThrow(Exception('Query failed'));

        final result = await repository.getDuelHistory(tUserModel.id);

        expect(result.isLeft(), isTrue);
      });
    });

    // ─── updateStepCount ──────────────────────────────────────────────────────
    group('updateStepCount', () {
      final steps = duel.StepCount(3000);

      test('returns updated Duel entity on success', () async {
        when(
          () => mockDataSource.updateStepCount(
            duelId: tDuelId,
            userId: tUserModel.id,
            steps: steps.value,
          ),
        ).thenAnswer((_) async => tActiveDuelDto());

        final result = await repository.updateStepCount(
          duelId: tDuelId,
          userId: tUserModel.id,
          steps: steps,
        );

        expect(result.isRight(), isTrue);
      });

      test('returns ServerFailure when datasource throws', () async {
        when(
          () => mockDataSource.updateStepCount(
            duelId: tDuelId,
            userId: tUserModel.id,
            steps: steps.value,
          ),
        ).thenThrow(Exception('Write permission denied'));

        final result = await repository.updateStepCount(
          duelId: tDuelId,
          userId: tUserModel.id,
          steps: steps,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });
  });
}
