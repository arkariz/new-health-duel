import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:health_duel/features/duel/presentation/pages/active_duel_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelBloc mockDuelBloc;

  setUp(() {
    mockDuelBloc = MockDuelBloc();
  });

  Widget buildSubject({
    String duelId = tDuelId,
    String userId = 'test-user-123',
  }) {
    return MaterialApp(
      home: BlocProvider<DuelBloc>.value(
        value: mockDuelBloc,
        child: ActiveDuelScreen(duelId: duelId, currentUserId: userId),
      ),
    );
  }

  group('ActiveDuelScreen', () {
    testWidgets('shows loading state with message', (tester) async {
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([
          const DuelLoading(message: 'Loading duel...'),
        ]),
        initialState: const DuelLoading(message: 'Loading duel...'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppBar with Active Duel title', (tester) async {
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([const DuelInitial()]),
        initialState: const DuelInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Active Duel'), findsOneWidget);
    });

    testWidgets('shows error state with message on DuelError', (tester) async {
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([const DuelError(tDuelErrorMessage)]),
        initialState: const DuelError(tDuelErrorMessage),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text(tDuelErrorMessage), findsOneWidget);
    });

    testWidgets('shows participant names on DuelLoaded', (tester) async {
      final now = DateTime.now();
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([
          DuelLoaded(
            duel: tActiveDuel,
            lastSyncTime: now,
            currentTime: now,
          ),
        ]),
        initialState: DuelLoaded(
          duel: tActiveDuel,
          lastSyncTime: now,
          currentTime: now,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('You'), findsAtLeastNWidgets(1));
      expect(find.text('Opponent'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows sync/refresh button when duel is loaded',
        (tester) async {
      final now = DateTime.now();
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([
          DuelLoaded(
            duel: tActiveDuel,
            lastSyncTime: now,
            currentTime: now,
          ),
        ]),
        initialState: DuelLoaded(
          duel: tActiveDuel,
          lastSyncTime: now,
          currentTime: now,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('dispatches DuelManualRefreshRequested on refresh tap',
        (tester) async {
      final now = DateTime.now();
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([
          DuelLoaded(duel: tActiveDuel, lastSyncTime: now, currentTime: now),
        ]),
        initialState:
            DuelLoaded(duel: tActiveDuel, lastSyncTime: now, currentTime: now),
      );

      await tester.pumpWidget(buildSubject(duelId: tDuelId));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      verify(
        () => mockDuelBloc.add(const DuelManualRefreshRequested(tDuelId)),
      ).called(1);
    });

    testWidgets('dispatches DuelLoadRequested after first frame', (tester) async {
      whenListen(
        mockDuelBloc,
        Stream<DuelState>.fromIterable([const DuelInitial()]),
        initialState: const DuelInitial(),
      );

      await tester.pumpWidget(buildSubject(duelId: tDuelId));
      await tester.pump(); // trigger postFrameCallback

      verify(
        () => mockDuelBloc.add(const DuelLoadRequested(tDuelId)),
      ).called(1);
    });
  });
}
