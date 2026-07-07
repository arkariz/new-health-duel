import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockGetActiveDuels mockGetActiveDuels;
  late MockGetPendingDuels mockGetPendingDuels;
  late MockGetSentDuels mockGetSentDuels;
  late MockGetDuelHistory mockGetDuelHistory;
  late MockAcceptDuel mockAcceptDuel;
  late MockDeclineDuel mockDeclineDuel;
  late MockSyncHealthData mockSyncHealthData;
  late MockCheckHealthPermissions mockCheckHealthPermissions;
  late MockCompleteDuel mockCompleteDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockGetActiveDuels = MockGetActiveDuels();
    mockGetPendingDuels = MockGetPendingDuels();
    mockGetDuelHistory = MockGetDuelHistory();
    mockAcceptDuel = MockAcceptDuel();
    mockDeclineDuel = MockDeclineDuel();
    mockSyncHealthData = MockSyncHealthData();
    mockCompleteDuel = MockCompleteDuel();
    // Empty by default so tests that don't care about outgoing challenges
    // don't need to stub it explicitly; existing [Loading, Loaded]
    // expectations remain exact.
    mockGetSentDuels = MockGetSentDuels()
      ..setupSuccess('test-user-123', []);
    // Not authorized by default so the background health-sync branch (which
    // would emit an extra refreshed DuelListLoaded) stays inactive and
    // existing [Loading, Loaded] expectations remain exact.
    mockCheckHealthPermissions = MockCheckHealthPermissions()
      ..setupSuccess(HealthPermissionStatus.notDetermined);
  });

  DuelListBloc buildBloc() => DuelListBloc(
        getActiveDuels: mockGetActiveDuels,
        getPendingDuels: mockGetPendingDuels,
        getSentDuels: mockGetSentDuels,
        getDuelHistory: mockGetDuelHistory,
        acceptDuel: mockAcceptDuel,
        declineDuel: mockDeclineDuel,
        syncHealthData: mockSyncHealthData,
        checkHealthPermissions: mockCheckHealthPermissions,
        completeDuel: mockCompleteDuel,
      );

  group('DuelListBloc', () {
    test('initial state is DuelListInitial', () {
      expect(buildBloc().state, const DuelListInitial());
    });

    // ─── DuelListLoadRequested ─────────────────────────────────────────────
    group('DuelListLoadRequested', () {
      const userId = 'test-user-123';

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListLoaded] with all three lists on success',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, [tActiveDuel]);
          mockGetPendingDuels.setupSuccess(userId, [tPendingDuel]);
          mockGetDuelHistory.setupSuccess(userId, [tCompletedDuel]);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListLoaded>()
              .having((s) => s.activeDuels.map((d) => d.id), 'activeDuelIds', [tDuelId])
              .having((s) => s.pendingDuels.map((d) => d.id), 'pendingDuelIds', [tPendingDuelId])
              .having((s) => s.historyDuels.map((d) => d.id), 'historyDuelIds', [tHistoryDuelId]),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListLoaded] with sent duels populated',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetSentDuels.setupSuccess(userId, [tSentDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListLoaded>().having(
            (s) => s.sentDuels.map((d) => d.id),
            'sentDuelIds',
            [tSentDuelId],
          ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListLoaded] with empty lists when user has no duels',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetDuelHistory.setupSuccess(userId, []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListLoaded>()
              .having((s) => s.activeDuels, 'activeDuels', isEmpty)
              .having((s) => s.pendingDuels, 'pendingDuels', isEmpty)
              .having((s) => s.sentDuels, 'sentDuels', isEmpty)
              .having((s) => s.historyDuels, 'historyDuels', isEmpty),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListError] when sent duels fetch fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetSentDuels.setupFailure(
            userId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          mockGetDuelHistory.setupSuccess(userId, []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListError>().having(
            (s) => s.message,
            'message',
            tDuelErrorMessage,
          ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListError] when active duels fetch fails',
        build: () {
          mockGetActiveDuels.setupFailure(
            userId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetDuelHistory.setupSuccess(userId, []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListError>().having(
            (s) => s.message,
            'message',
            tDuelErrorMessage,
          ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListError] when pending duels fetch fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupFailure(
            userId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          mockGetDuelHistory.setupSuccess(userId, []);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListError>().having(
            (s) => s.message,
            'message',
            tDuelErrorMessage,
          ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits [DuelListLoading, DuelListError] when history fetch fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetDuelHistory.setupFailure(
            userId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListError>(),
        ],
      );
    });

    // ─── Expired duel sweep ────────────────────────────────────────────────
    group('expired duel sweep', () {
      const userId = 'test-user-123';

      blocTest<DuelListBloc, DuelListState>(
        'completes expired active duels and moves them to history',
        build: () {
          // First fetch returns the expired duel; refetch after the sweep
          // returns the post-completion lists.
          var activeCalls = 0;
          when(() => mockGetActiveDuels(userId)).thenAnswer((_) async {
            activeCalls++;
            return activeCalls == 1
                ? Right([tExpiredActiveDuel])
                : const Right(<Duel>[]);
          });
          var historyCalls = 0;
          when(() => mockGetDuelHistory(userId)).thenAnswer((_) async {
            historyCalls++;
            return historyCalls == 1
                ? const Right(<Duel>[])
                : Right([tJustCompletedDuel]);
          });
          mockGetPendingDuels.setupSuccess(userId, []);
          mockCompleteDuel.setupSuccess(tDuelId, tJustCompletedDuel);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListLoaded>()
              .having((s) => s.activeDuels, 'activeDuels', isEmpty)
              .having(
                (s) => s.historyDuels.map((d) => d.id),
                'historyDuelIds',
                [tDuelId],
              ),
        ],
        verify: (_) {
          verify(() => mockCompleteDuel(tDuelId)).called(1);
        },
      );

      blocTest<DuelListBloc, DuelListState>(
        'still emits DuelListLoaded when completing an expired duel fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, [tExpiredActiveDuel]);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockCompleteDuel.setupFailure(
            tDuelId,
            const ServerFailure(message: 'permission denied'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const DuelListLoadRequested(userId)),
        expect: () => [
          const DuelListLoading(),
          isA<DuelListLoaded>().having(
            (s) => s.activeDuels.map((d) => d.id),
            'activeDuelIds',
            [tDuelId],
          ),
        ],
        verify: (_) {
          verify(() => mockCompleteDuel(tDuelId)).called(1);
        },
      );
    });

    // ─── DuelAcceptRequested ───────────────────────────────────────────────
    group('DuelAcceptRequested', () {
      const userId = 'test-user-123';

      blocTest<DuelListBloc, DuelListState>(
        'moves accepted duel from pendingDuels to activeDuels and emits success effect',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, [tPendingDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockAcceptDuel.setupSuccess(tPendingDuelId, tActiveDuel);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const DuelListLoadRequested(userId));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const DuelAcceptRequested(tPendingDuelId));
        },
        skip: 2, // skip Loading and initial Loaded
        expect: () => [
          isA<DuelListLoaded>()
              .having(
                (s) => s.activeDuels.map((d) => d.id),
                'activeDuelIds',
                contains(tDuelId),
              )
              .having(
                (s) => s.pendingDuels.map((d) => d.id),
                'pendingDuelIds',
                isNot(contains(tPendingDuelId)),
              )
              .having(
                (s) => s.effect,
                'effect',
                isA<ShowSnackBarEffect>(),
              ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits DuelListLoaded with error effect when accept fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, [tPendingDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockAcceptDuel.setupFailure(
            tPendingDuelId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const DuelListLoadRequested(userId));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const DuelAcceptRequested(tPendingDuelId));
        },
        skip: 2,
        expect: () => [
          isA<DuelListLoaded>().having(
            (s) => s.effect,
            'effect',
            isA<ShowSnackBarEffect>(),
          ),
        ],
      );
    });

    // ─── DuelDeclineRequested ──────────────────────────────────────────────
    group('DuelDeclineRequested', () {
      const userId = 'test-user-123';

      blocTest<DuelListBloc, DuelListState>(
        'removes declined duel from pendingDuels and emits info effect',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, [tPendingDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockDeclineDuel.setupSuccess(tPendingDuelId);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const DuelListLoadRequested(userId));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const DuelDeclineRequested(tPendingDuelId));
        },
        skip: 2,
        expect: () => [
          isA<DuelListLoaded>()
              .having(
                (s) => s.pendingDuels.map((d) => d.id),
                'pendingDuelIds',
                isNot(contains(tPendingDuelId)),
              )
              .having(
                (s) => s.effect,
                'effect',
                isA<ShowSnackBarEffect>(),
              ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'emits DuelListLoaded with error effect when decline fails',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, [tPendingDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockDeclineDuel.setupFailure(
            tPendingDuelId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const DuelListLoadRequested(userId));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const DuelDeclineRequested(tPendingDuelId));
        },
        skip: 2,
        expect: () => [
          isA<DuelListLoaded>().having(
            (s) => s.effect,
            'effect',
            isA<ShowSnackBarEffect>(),
          ),
        ],
      );

      blocTest<DuelListBloc, DuelListState>(
        'removes cancelled duel from sentDuels and emits cancel effect',
        build: () {
          mockGetActiveDuels.setupSuccess(userId, []);
          mockGetPendingDuels.setupSuccess(userId, []);
          mockGetSentDuels.setupSuccess(userId, [tSentDuel]);
          mockGetDuelHistory.setupSuccess(userId, []);
          mockDeclineDuel.setupSuccess(tSentDuelId);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const DuelListLoadRequested(userId));
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const DuelDeclineRequested(tSentDuelId));
        },
        skip: 2,
        expect: () => [
          isA<DuelListLoaded>()
              .having(
                (s) => s.sentDuels.map((d) => d.id),
                'sentDuelIds',
                isNot(contains(tSentDuelId)),
              )
              .having(
                (s) => s.effect,
                'effect',
                isA<ShowSnackBarEffect>()
                    .having((e) => e.message, 'message', 'Challenge cancelled.'),
              ),
        ],
      );
    });
  });
}
