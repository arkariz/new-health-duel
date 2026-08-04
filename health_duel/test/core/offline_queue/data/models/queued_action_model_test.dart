import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/offline_queue/data/models/queued_action_model.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';

void main() {
  group('QueuedActionModel', () {
    test('round-trips through JSON preserving all fields', () {
      final entity = QueuedAction(
        id: '123_acceptDuel',
        type: OfflineActionType.acceptDuel,
        payload: const {'duelId': 'duel-1'},
        dedupKey: 'duel_duel-1',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        attemptCount: 2,
        lastAttemptAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );

      final json = QueuedActionModel.fromEntity(entity).toJson();
      final roundTripped = QueuedActionModel.fromJson(json).toEntity();

      expect(roundTripped, entity);
    });

    test('round-trips a null lastAttemptAt', () {
      final entity = QueuedAction(
        id: '123_createDuel',
        type: OfflineActionType.createDuel,
        payload: const {'challengerId': 'a', 'challengedId': 'b'},
        dedupKey: 'create_a_b',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      final json = QueuedActionModel.fromEntity(entity).toJson();
      final roundTripped = QueuedActionModel.fromJson(json).toEntity();

      expect(roundTripped, entity);
      expect(roundTripped!.lastAttemptAt, isNull);
    });

    test('toEntity returns null for an unrecognized type', () {
      final json = QueuedActionModel(
        id: '123_futureType',
        type: 'someFutureActionType',
        payload: const {},
        dedupKey: 'k',
        createdAtMillis: 1000,
        attemptCount: 0,
      ).toJson();

      final model = QueuedActionModel.fromJson(json);

      expect(model.toEntity(), isNull);
    });
  });
}
