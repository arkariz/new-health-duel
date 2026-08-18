import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:health_duel/features/duel/presentation/widgets/share_card_widget.dart';

import '../../../../helpers/helpers.dart';

void main() {
  Widget buildSubject({required Duel duel, String userId = 'test-user-123'}) {
    return MaterialApp(
      home: Scaffold(
        body: ShareCardWidget(duel: duel, currentUserId: userId),
      ),
    );
  }

  group('ShareCardWidget', () {
    testWidgets('has a fixed 600x315 logical size', (tester) async {
      await tester.pumpWidget(buildSubject(duel: tCompletedDuel));
      await tester.pump();

      expect(
        tester.getSize(find.byType(ShareCardWidget)),
        const Size(600, 315),
      );
    });

    testWidgets('shows winner trophy and both names when winner side',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(duel: tCompletedDuel, userId: tUserModel.id),
      );
      await tester.pump();

      expect(find.text(tUserModel.name), findsOneWidget);
      expect(find.text(tOpponentModel.name), findsOneWidget);
      expect(find.text('🏆'), findsAtLeastNWidgets(1));
      expect(find.text('🙇'), findsOneWidget);
    });

    testWidgets("shows tie handshake emoji for a tied duel", (tester) async {
      final tieDuel = Duel(
        id: tHistoryDuelId,
        challengerId: tUserModel.id,
        challengedId: tOpponentModel.id,
        challengerName: tUserModel.name,
        challengedName: tOpponentModel.name,
        challengerValue: duel.StepCount(5000),
        challengedValue: duel.StepCount(5000),
        status: DuelStatus.completed,
        startTime: tDuelStartTime,
        endTime: tDuelEndTime,
        createdAt: tDuelCreatedAt,
        acceptedAt: tDuelAcceptedAt,
        completedAt: tDuelCompletedAt,
      );

      await tester.pumpWidget(buildSubject(duel: tieDuel));
      await tester.pump();

      expect(find.text("It's a tie!"), findsOneWidget);
      expect(find.text('🏆'), findsOneWidget); // brand mark only, no winner
      expect(find.text('🙇'), findsNothing);
    });

    testWidgets('shows branding, title and CTA text', (tester) async {
      await tester.pumpWidget(buildSubject(duel: tCompletedDuel));
      await tester.pump();

      expect(find.text('HEALTH DUEL'), findsOneWidget);
      expect(find.text('24-Hour Step Duel'), findsOneWidget);
      expect(find.text('Challenge me on Health Duel!'), findsOneWidget);
    });

    testWidgets('shows step counts for both participants', (tester) async {
      await tester.pumpWidget(buildSubject(duel: tCompletedDuel));
      await tester.pump();

      expect(find.text('8.0k steps'), findsOneWidget);
      expect(find.text('6.5k steps'), findsOneWidget);
    });
  });
}
