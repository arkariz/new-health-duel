import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockGetActiveDuels mockGetActiveDuels;
  late MockGetPendingDuels mockGetPendingDuels;
  late MockGetDuelHistory mockGetDuelHistory;
  late MockAcceptDuel mockAcceptDuel;
  late MockDeclineDuel mockDeclineDuel;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockGetActiveDuels = MockGetActiveDuels();
    mockGetPendingDuels = MockGetPendingDuels();
    mockGetDuelHistory = MockGetDuelHistory();
    mockAcceptDuel = MockAcceptDuel();
    mockDeclineDuel = MockDeclineDuel();
  });

  DuelListBloc buildBloc() => DuelListBloc(
        getActiveDuels: mockGetActiveDuels,
        getPendingDuels: mockGetPendingDuels,
        getDuelHistory: mockGetDuelHistory,
        acceptDuel: mockAcceptDuel,
        declineDuel: mockDeclineDuel,
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
              .having((s) => s.historyDuels, 'historyDuels', isEmpty),
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
    });
  });
}
