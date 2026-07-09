import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:health_duel/features/duel/presentation/pages/duel_result_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockDuelShareService mockShareService;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockShareService = MockDuelShareService();
  });

  Widget buildSubject({required Duel duel, String userId = 'test-user-123'}) {
    return MaterialApp(
      home: DuelResultScreen(
        duel: duel,
        currentUserId: userId,
        shareService: mockShareService,
        captureOverride: (_) async => Uint8List.fromList([1, 2, 3]),
      ),
    );
  }

  group('DuelResultScreen', () {
    testWidgets('shows AppBar with Duel Result title', (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel),
      );
      await tester.pump();

      expect(find.text('Duel Result'), findsOneWidget);
    });

    testWidgets('shows Victory when current user is the winner', (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
      );
      await tester.pump();

      expect(find.text('Victory!'), findsOneWidget);
    });

    testWidgets('shows Defeat when current user is the loser', (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel, userId: tOpponentModel.id),
      );
      await tester.pump();

      expect(find.text('Defeat'), findsOneWidget);
    });

    testWidgets('shows Tie when both players have equal steps', (tester) async {
      final tieDuel = Duel(
        id: tHistoryDuelId,
        challengerId: tUserModel.id,
        challengedId: tOpponentModel.id,
        challengerName: tUserModel.name,
        challengedName: tOpponentModel.name,
        challengerSteps: duel.StepCount(5000),
        challengedSteps: duel.StepCount(5000),
        status: DuelStatus.completed,
        startTime: tDuelStartTime,
        endTime: tDuelEndTime,
        createdAt: tDuelCreatedAt,
        acceptedAt: tDuelAcceptedAt,
        completedAt: tDuelCompletedAt,
      );

      await tester.pumpWidget(
        buildSubject(duel: tieDuel, userId: tUserModel.id),
      );
      await tester.pump();

      expect(find.text("It's a Tie!"), findsOneWidget);
    });

    testWidgets('shows step counts for both players', (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
      );
      await tester.pump();

      // Winner steps (8000 → 8.0k) and loser steps (6500 → 6.5k) should be visible
      expect(find.text('8.0k'), findsAtLeastNWidgets(1));
      expect(find.text('6.5k'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows not-completed message when duel is still active',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tActiveDuel, userId: tUserModel.id),
      );
      await tester.pump();

      expect(find.text('Duel Still Active'), findsOneWidget);
    });

    testWidgets('shows share button when duel is completed', (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
      );
      await tester.pump();

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    group('sharing', () {
      testWidgets('tapping Share calls shareService.shareImage', (tester) async {
        mockShareService.setupSuccess();

        await tester.pumpWidget(
          buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.share_rounded));
        await tester.pumpAndSettle();

        verify(
          () => mockShareService.shareImage(
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
            text: any(named: 'text'),
          ),
        ).called(1);
      });

      testWidgets('shows a loading indicator while sharing', (tester) async {
        mockShareService.setupSuccess();

        // Real capture/share are instant no-op mocks elsewhere in this file,
        // which resolve within the same pump() call — too fast to observe
        // the loading state. Add an artificial delay here specifically so
        // the in-flight state is actually observable.
        await tester.pumpWidget(
          MaterialApp(
            home: DuelResultScreen(
              duel: tCompletedDuel,
              currentUserId: tUserModel.id,
              shareService: mockShareService,
              captureOverride: (_) => Future.delayed(
                const Duration(milliseconds: 50),
                () => Uint8List.fromList([1, 2, 3]),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.share_rounded));
        await tester.pump(); // one frame — share still in flight

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('shows a success snackbar after sharing', (tester) async {
        mockShareService.setupSuccess();

        await tester.pumpWidget(
          buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.share_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Shared!'), findsOneWidget);
      });

      testWidgets('shows an error snackbar when sharing fails', (tester) async {
        mockShareService.setupFailure();

        await tester.pumpWidget(
          buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
        );
        await tester.pump();

        await tester.tap(find.byIcon(Icons.share_rounded));
        await tester.pumpAndSettle();

        expect(
          find.text('Could not share result. Please try again.'),
          findsOneWidget,
        );
      });
    });
  });
}
