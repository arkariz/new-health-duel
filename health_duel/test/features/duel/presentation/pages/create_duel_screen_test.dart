import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_state.dart';
import 'package:health_duel/features/duel/presentation/pages/create_duel_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockCreateDuelBloc mockCreateDuelBloc;

  setUp(() {
    mockCreateDuelBloc = MockCreateDuelBloc();
  });

  Widget buildSubject({String userId = 'test-user-123'}) {
    return MaterialApp(
      home: BlocProvider<CreateDuelBloc>.value(
        value: mockCreateDuelBloc,
        child: CreateDuelScreen(currentUserId: userId),
      ),
    );
  }

  group('CreateDuelScreen', () {
    testWidgets('shows loading indicator while opponents are loading',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          const CreateDuelLoadingOpponents(),
        ]),
        initialState: const CreateDuelLoadingOpponents(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppBar with New Challenge title', (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([const CreateDuelInitial()]),
        initialState: const CreateDuelInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('New Challenge'), findsOneWidget);
    });

    testWidgets('shows Select Opponent section and opponent list when ready',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          CreateDuelReady(opponents: [tOpponentModel, tOpponent2Model]),
        ]),
        initialState:
            CreateDuelReady(opponents: [tOpponentModel, tOpponent2Model]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Select Opponent'), findsOneWidget);
      expect(find.text(tOpponentModel.name), findsOneWidget);
      expect(find.text(tOpponent2Model.name), findsOneWidget);
    });

    testWidgets(
        'SEND CHALLENGE button is disabled when no opponent is selected',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          CreateDuelReady(opponents: [tOpponentModel]),
        ]),
        initialState: CreateDuelReady(opponents: [tOpponentModel]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'SEND CHALLENGE button becomes enabled after selecting an opponent',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          CreateDuelReady(opponents: [tOpponentModel]),
        ]),
        initialState: CreateDuelReady(opponents: [tOpponentModel]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Tap opponent to select
      await tester.tap(find.text(tOpponentModel.name));
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('dispatches CreateDuelSubmitted when button is tapped',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          CreateDuelReady(opponents: [tOpponentModel]),
        ]),
        initialState: CreateDuelReady(opponents: [tOpponentModel]),
      );

      await tester.pumpWidget(buildSubject(userId: tUserModel.id));
      await tester.pump();

      // Select opponent first
      await tester.tap(find.text(tOpponentModel.name));
      await tester.pump();

      // Tap the button
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      verify(
        () => mockCreateDuelBloc.add(
          CreateDuelSubmitted(
            challengerId: tUserModel.id,
            challengedId: tOpponentModel.id,
            challengedName: tOpponentModel.name,
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches CreateDuelOpponentsRequested on init',
        (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([const CreateDuelInitial()]),
        initialState: const CreateDuelInitial(),
      );

      await tester.pumpWidget(buildSubject(userId: tUserModel.id));
      await tester.pump();

      verify(
        () => mockCreateDuelBloc.add(
          CreateDuelOpponentsRequested(tUserModel.id),
        ),
      ).called(1);
    });

    testWidgets('shows error state on CreateDuelFailure', (tester) async {
      whenListen(
        mockCreateDuelBloc,
        Stream<CreateDuelState>.fromIterable([
          CreateDuelFailure(tDuelErrorMessage),
        ]),
        initialState: CreateDuelFailure(tDuelErrorMessage),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text(tDuelErrorMessage), findsOneWidget);
    });
  });
}
