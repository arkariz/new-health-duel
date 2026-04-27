import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';
import 'package:health_duel/features/duel/presentation/pages/duel_list_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockDuelListBloc mockDuelListBloc;

  setUp(() {
    mockDuelListBloc = MockDuelListBloc();
  });

  Widget buildSubject({String userId = 'test-user-123'}) {
    return MaterialApp(
      home: BlocProvider<DuelListBloc>.value(
        value: mockDuelListBloc,
        child: DuelListScreen(currentUserId: userId),
      ),
    );
  }

  group('DuelListScreen', () {
    testWidgets('shows loading indicator on DuelListLoading', (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([const DuelListLoading()]),
        initialState: const DuelListLoading(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders tab bar with Active, Pending, History tabs',
        (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([
          DuelListLoaded(
            activeDuels: [],
            pendingDuels: [],
            historyDuels: [],
          ),
        ]),
        initialState: DuelListLoaded(
          activeDuels: [],
          pendingDuels: [],
          historyDuels: [],
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('shows AppBar with My Duels title', (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([const DuelListInitial()]),
        initialState: const DuelListInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('My Duels'), findsOneWidget);
    });

    testWidgets('shows empty state text on Active tab when no active duels',
        (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([
          DuelListLoaded(
            activeDuels: [],
            pendingDuels: [],
            historyDuels: [],
          ),
        ]),
        initialState: DuelListLoaded(
          activeDuels: [],
          pendingDuels: [],
          historyDuels: [],
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Empty state should describe no active duels
      expect(find.text('No Active Duels'), findsOneWidget);
    });

    testWidgets('shows error state with retry button on DuelListError',
        (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([
          DuelListError(tDuelErrorMessage),
        ]),
        initialState: DuelListError(tDuelErrorMessage),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows duel card when active duel is present', (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([
          DuelListLoaded(
            activeDuels: [tActiveDuel],
            pendingDuels: [],
            historyDuels: [],
          ),
        ]),
        initialState: DuelListLoaded(
          activeDuels: [tActiveDuel],
          pendingDuels: [],
          historyDuels: [],
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Challenger and challenged names should appear on the card
      expect(find.text(tUserModel.name), findsAtLeastNWidgets(1));
      expect(find.text(tOpponentModel.name), findsAtLeastNWidgets(1));
    });

    testWidgets('switches to Pending tab and shows pending duels',
        (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([
          DuelListLoaded(
            activeDuels: [],
            pendingDuels: [tPendingDuel],
            historyDuels: [],
          ),
        ]),
        initialState: DuelListLoaded(
          activeDuels: [],
          pendingDuels: [tPendingDuel],
          historyDuels: [],
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Tap the Pending tab
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      // Challenger name should appear in the pending card
      expect(find.text(tOpponentModel.name), findsAtLeastNWidgets(1));
    });

    testWidgets('dispatches DuelListLoadRequested on init', (tester) async {
      whenListen(
        mockDuelListBloc,
        Stream<DuelListState>.fromIterable([const DuelListInitial()]),
        initialState: const DuelListInitial(),
      );

      await tester.pumpWidget(buildSubject(userId: tUserModel.id));
      await tester.pump();

      verify(
        () => mockDuelListBloc.add(DuelListLoadRequested(tUserModel.id)),
      ).called(1);
    });
  });
}
