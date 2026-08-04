import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/presentation/widgets/sync_indicator.dart';

void main() {
  Widget buildSubject({
    DateTime? lastSyncTime,
    bool isSyncing = false,
    VoidCallback? onRefresh,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SyncIndicator(
          lastSyncTime: lastSyncTime,
          isSyncing: isSyncing,
          onRefresh: onRefresh,
        ),
      ),
    );
  }

  group('SyncIndicator', () {
    testWidgets('shows "Not synced yet" when lastSyncTime is null',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Not synced yet'), findsOneWidget);
    });

    testWidgets('shows relative last-synced time when lastSyncTime is set',
        (tester) async {
      final lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpWidget(buildSubject(lastSyncTime: lastSyncTime));

      expect(find.textContaining('Last synced'), findsOneWidget);
      expect(find.text('Not synced yet'), findsNothing);
    });

    testWidgets('shows syncing text and progress indicator while syncing',
        (tester) async {
      await tester.pumpWidget(buildSubject(isSyncing: true));

      expect(find.text('Syncing health data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows refresh button when onRefresh is provided',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(onRefresh: () => tapped = true),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
