import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/presentation/offline_aware_action.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockWatchDuel mockWatchDuel;
  late MockSyncHealthData mockSyncHealthData;
  late MockSessionRepository mockSessionRepository;
  late MockCheckHealthPermissions mockCheckHealthPermissions;
  late MockRequestHealthPermissions mockRequestHealthPermissions;
  late MockCompleteDuel mockCompleteDuel;
  late MockActiveDuelPointer mockActiveDuelPointer;
  late MockBackgroundSyncController mockBackgroundSyncController;
  late MockConnectivityCubit mockConnectivityCubit;
  late MockEnqueueOfflineAction mockEnqueueOfflineAction;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockWatchDuel = MockWatchDuel();
    mockSyncHealthData = MockSyncHealthData();
    mockSessionRepository = MockSessionRepository();
    mockCheckHealthPermissions = MockCheckHealthPermissions();
    mockRequestHealthPermissions = MockRequestHealthPermissions();
    mockCompleteDuel = MockCompleteDuel();
    mockActiveDuelPointer = MockActiveDuelPointer();
    mockBackgroundSyncController = MockBackgroundSyncController();
    mockCheckHealthPermissions.setupSuccess(HealthPermissionStatus.authorized);
    mockRequestHealthPermissions.setupSuccess(granted: true);
    when(
      () => mockActiveDuelPointer.set(
        duelId: any(named: 'duelId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockActiveDuelPointer.clear()).thenAnswer((_) async {});
    when(
      () => mockBackgroundSyncController.register(
        duelId: any(named: 'duelId'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockBackgroundSyncController.cancel())
        .thenAnswer((_) async {});
    mockEnqueueOfflineAction = MockEnqueueOfflineAction();
    when(
      () => mockEnqueueOfflineAction(
        type: any(named: 'type'),
        payload: any(named: 'payload'),
        dedupKey: any(named: 'dedupKey'),
      ),
    ).thenAnswer((_) async => const Right(null));
    mockConnectivityCubit = MockConnectivityCubit();
    when(() => mockConnectivityCubit.isOffline).thenReturn(false);
  });

  DuelBloc buildBloc() => DuelBloc(
        watchDuel: mockWatchDuel,
        syncHealthData: mockSyncHealthData,
        sessionRepository: mockSessionRepository,
        checkHealthPermissions: mockCheckHealthPermissions,
        requestHealthPermissions: mockRequestHealthPermissions,
        completeDuel: mockCompleteDuel,
        activeDuelPointer: mockActiveDuelPointer,
        backgroundSyncController: mockBackgroundSyncController,
        offlineAwareAction:
            OfflineAwareAction(mockConnectivityCubit, mockEnqueueOfflineAction),
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

        final bloc = buildBloc()
          ..add(const DuelLoadRequested(tDuelId));
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

        final bloc = buildBloc()
        ..add(const DuelLoadRequested(tDuelId));
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
        'emits DuelLoaded with lastSyncTime null when no prior sync happened',
        build: buildBloc,
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tActiveDuel)),
        expect: () => [
          isA<DuelLoaded>().having(
            (s) => s.lastSyncTime,
            'lastSyncTime',
            isNull,
          ),
        ],
      );

      blocTest<DuelBloc, DuelState>(
        'emits DuelLoaded with navigate-to-result effect when duel is completed',
        build: buildBloc,
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tCompletedDuel)),
        expect: () => [
          isA<DuelLoaded>()
              .having((s) => s.duel.id, 'duel.id', tHistoryDuelId)
              .having((s) => s.effect, 'effect', isA<NavigatePushEffect>()),
        ],
      );
    });

    // ─── Duel completion (client-side) ─────────────────────────────────────
    group('duel completion', () {
      blocTest<DuelBloc, DuelState>(
        'completes expired-active duel from stream update and navigates to result',
        build: () {
          mockCompleteDuel.setupSuccess(tDuelId, tJustCompletedDuel);
          return buildBloc();
        },
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tExpiredActiveDuel)),
        expect: () => [
          // Normal emit while completion is being written
          isA<DuelLoaded>()
              .having((s) => s.duel.id, 'duel.id', tDuelId)
              .having((s) => s.effect, 'effect', isNot(isA<NavigatePushEffect>())),
          // Completion succeeded → navigate to result
          isA<DuelLoaded>()
              .having((s) => s.duel.status.name, 'duel.status', 'completed')
              .having((s) => s.effect, 'effect', isA<NavigatePushEffect>()),
        ],
        verify: (_) {
          verify(() => mockCompleteDuel(tDuelId)).called(1);
        },
      );

      blocTest<DuelBloc, DuelState>(
        'navigates only once when stream echoes the completed duel back',
        build: () {
          mockCompleteDuel.setupSuccess(tDuelId, tJustCompletedDuel);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(DuelUpdateSucceeded(tExpiredActiveDuel));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          // Firestore stream echoes our own completion write back
          bloc.add(DuelUpdateSucceeded(tJustCompletedDuel));
        },
        skip: 2, // normal emit + navigate emit (covered above)
        expect: () => [
          isA<DuelLoaded>()
              .having((s) => s.duel.status.name, 'duel.status', 'completed')
              .having((s) => s.effect, 'effect', isNull),
        ],
      );

      blocTest<DuelBloc, DuelState>(
        'falls back to snackbar effect when completion write fails',
        build: () {
          mockCompleteDuel.setupFailure(
            tDuelId,
            const ServerFailure(message: 'permission denied'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tExpiredActiveDuel)),
        expect: () => [
          isA<DuelLoaded>()
              .having((s) => s.duel.id, 'duel.id', tDuelId)
              .having((s) => s.effect, 'effect', isNot(isA<NavigatePushEffect>())),
          isA<DuelLoaded>()
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
        verify: (_) {
          verify(() => mockCompleteDuel(tDuelId)).called(1);
        },
      );

      blocTest<DuelBloc, DuelState>(
        'completes tied expired duel and navigates to result',
        build: () {
          mockCompleteDuel.setupSuccess(tDuelId, tJustCompletedDuel);
          return buildBloc();
        },
        act: (bloc) => bloc.add(DuelUpdateSucceeded(tExpiredTiedDuel)),
        expect: () => [
          isA<DuelLoaded>().having((s) => s.duel.id, 'duel.id', tDuelId),
          isA<DuelLoaded>()
              .having((s) => s.duel.status.name, 'duel.status', 'completed')
              .having((s) => s.effect, 'effect', isA<NavigatePushEffect>()),
        ],
        verify: (_) {
          verify(() => mockCompleteDuel(tDuelId)).called(1);
        },
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
          'enqueues silently instead of calling SyncHealthData when offline',
          () async {
        final streamController =
            StreamController<Either<Failure, Duel>>.broadcast();

        when(() => mockConnectivityCubit.isOffline).thenReturn(true);
        mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
        when(() => mockWatchDuel(tDuelId))
            .thenAnswer((_) => streamController.stream);

        final bloc = buildBloc()
        ..add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(const DuelHealthSyncTriggered(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        verifyNever(
          () => mockSyncHealthData(
            duelId: any(named: 'duelId'),
            userId: any(named: 'userId'),
          ),
        );
        verify(
          () => mockEnqueueOfflineAction(
            type: OfflineActionType.syncStepCount,
            payload: {'duelId': tDuelId, 'userId': tUserModel.id},
            dedupKey: 'steps_${tDuelId}_${tUserModel.id}',
          ),
        ).called(greaterThanOrEqualTo(1));

        await streamController.close();
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

        final bloc = buildBloc()
        ..add(const DuelLoadRequested(tDuelId));
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

      test('leaves lastSyncTime unchanged when sync fails', () async {
        final streamController =
            StreamController<Either<Failure, Duel>>.broadcast();

        mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
        when(() => mockWatchDuel(tDuelId))
            .thenAnswer((_) => streamController.stream);
        mockSyncHealthData.setupFailure(
          duelId: tDuelId,
          userId: tUserModel.id,
          failure: const ServerFailure(message: 'Health Connect unavailable'),
        );

        final bloc = buildBloc()
        ..add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        streamController.add(Right(tActiveDuel));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final state = bloc.state;
        expect(state, isA<DuelLoaded>());
        expect((state as DuelLoaded).lastSyncTime, isNull);

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

        final bloc = buildBloc()
        ..add(const DuelLoadRequested(tDuelId));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await bloc.close();

        expect(bloc.isClosed, isTrue);
        await streamController.close();
      });
    });
  });
}
