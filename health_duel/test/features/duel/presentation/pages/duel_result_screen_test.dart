import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:health_duel/features/duel/presentation/pages/duel_result_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  Widget buildSubject({required Duel duel, String userId = 'test-user-123'}) {
    return MaterialApp(
      home: DuelResultScreen(duel: duel, currentUserId: userId),
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

      expect(find.text('Tie!'), findsOneWidget);
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
  });
}
