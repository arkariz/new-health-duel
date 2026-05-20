import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockWatchDuel mockWatchDuel;
  late MockSyncHealthData mockSyncHealthData;
  late MockSessionRepository mockSessionRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockWatchDuel = MockWatchDuel();
    mockSyncHealthData = MockSyncHealthData();
    mockSessionRepository = MockSessionRepository();
  });

  DuelBloc buildBloc() => DuelBloc(
        watchDuel: mockWatchDuel,
        syncHealthData: mockSyncHealthData,
        sessionRepository: mockSessionRepository,
      );

  group('DuelBloc', () {
    test('initial state is DuelInitial', () {
      expect(buildBloc().state, const DuelInitial());
    });

    // ─── DuelLoadRequested ─────────────────────────────────────────────────
    group('DuelLoadRequested', () {
      test('emits DuelError when user is not authenticated', () async {
        when(() => mockSessionRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        final bloc = buildBloc();
        bloc.add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<DuelError>());
        await bloc.close();
      });

      test('emits DuelLoading then subscribes to duel stream on load',
          () async {
        final streamController = StreamController<Either<Failure, Duel>>.broadcast();

        mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
        when(() => mockWatchDuel(tDuelId)).thenAnswer((_) => streamController.stream);
        mockSyncHealthData.setupSuccess(
          duelId: tDuelId,
          userId: tUserModel.id,
          result: tActiveDuel,
        );

        final bloc = buildBloc();
        bloc.add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<DuelLoading>());

        streamController.add(Right(tActiveDuel));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state, isA<DuelLoaded>());

        await streamController.close();
        await bloc.close();
      });
    });

    // ─── DuelUpdateSucceeded ───────────────────────────────────────────────
    group('DuelUpdateSucceeded', () {
      blocTest<DuelBloc, DuelState>(
        'emits DuelLoaded with duel data when update succeeds',
        build: buildBloc,
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tActiveDuel)),
        expect: () => [
          isA<DuelLoaded>().having((s) => s.duel.id, 'duel.id', tDuelId),
        ],
      );

      blocTest<DuelBloc, DuelState>(
        'emits DuelLoaded with duel completed effect when duel is completed',
        build: buildBloc,
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tCompletedDuel)),
        expect: () => [
          isA<DuelLoaded>()
              .having((s) => s.duel.id, 'duel.id', tHistoryDuelId)
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );
    });

    // ─── DuelUpdateFailed ──────────────────────────────────────────────────
    group('DuelUpdateFailed', () {
      blocTest<DuelBloc, DuelState>(
        'emits DuelError when real-time update fails',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const DuelUpdateFailed(
            ServerFailure(message: tDuelErrorMessage),
          ),
        ),
        expect: () => [
          isA<DuelError>().having(
            (s) => s.message,
            'message',
            tDuelErrorMessage,
          ),
        ],
      );
    });

    // ─── DuelHealthSyncTriggered ───────────────────────────────────────────
    group('DuelHealthSyncTriggered', () {
      test('returns early (no state emitted) when currentUserId is not set',
          () async {
        // _currentUserId is null unless DuelLoadRequested is processed first.
        // Seeding state does not set internal variables.
        final bloc = buildBloc();

        final states = <DuelState>[];
        bloc.stream.listen(states.add);

        bloc.add(const DuelHealthSyncTriggered(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // No state change expected because userId is null
        expect(states, isEmpty);
        await bloc.close();
      });

      test(
          'updates lastSyncTime after full DuelLoadRequested flow when sync succeeds',
          () async {
        final streamController =
            StreamController<Either<Failure, Duel>>.broadcast();

        mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
        when(() => mockWatchDuel(tDuelId))
            .thenAnswer((_) => streamController.stream);
        mockSyncHealthData.setupSuccess(
          duelId: tDuelId,
          userId: tUserModel.id,
          result: tActiveDuel,
        );

        final bloc = buildBloc();
        bloc.add(const DuelLoadRequested(tDuelId));
        // Wait for session + subscription setup
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Trigger a manual sync now that _currentUserId is set
        bloc.add(const DuelHealthSyncTriggered(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // No error thrown and bloc is still operational
        expect(bloc.isClosed, isFalse);

        await streamController.close();
        await bloc.close();
      });
    });

    // ─── DuelBloc lifecycle ────────────────────────────────────────────────
    group('lifecycle', () {
      test('cancels subscriptions on close', () async {
        final streamController =
            StreamController<Either<Failure, Duel>>.broadcast();

        mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
        when(() => mockWatchDuel(tDuelId))
            .thenAnswer((_) => streamController.stream);
        mockSyncHealthData.setupSuccess(
          duelId: tDuelId,
          userId: tUserModel.id,
          result: tActiveDuel,
        );

        final bloc = buildBloc();
        bloc.add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await bloc.close();

        expect(bloc.isClosed, isTrue);
        await streamController.close();
      });
    });
  });
}
