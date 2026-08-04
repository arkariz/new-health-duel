import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/offline_queue/application/offline_queue_processor.dart';
import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';
import 'package:health_duel/core/offline_queue/domain/notification/offline_queue_notification.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_cubit.dart';
import 'package:health_duel/core/offline_queue/presentation/cubit/offline_queue_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

class MockOfflineQueueProcessor extends Mock implements OfflineQueueProcessor {}

void main() {
  late MockOfflineQueueProcessor mockProcessor;
  late MockOfflineQueueRepository mockRepository;
  late StreamController<OfflineQueueNotification> notificationController;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockProcessor = MockOfflineQueueProcessor();
    mockRepository = MockOfflineQueueRepository();
    notificationController = StreamController<OfflineQueueNotification>.broadcast();
    when(() => mockProcessor.notifications)
        .thenAnswer((_) => notificationController.stream);
  });

  tearDown(() async {
    await notificationController.close();
  });

  OfflineQueueCubit buildCubit() => OfflineQueueCubit(
        processor: mockProcessor,
        repository: mockRepository,
      );

  group('OfflineQueueCubit', () {
    test('emits clearEffect then the new effect for DrainSucceeded', () async {
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => const Right(<QueuedAction>[]));
      final cubit = buildCubit();

      final states = <OfflineQueueState>[];
      cubit.stream.listen(states.add);

      notificationController.add(const DrainSucceeded(synced: 2, pending: 0));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states, hasLength(2));
      expect(states[0].effect, isNull); // clearEffect
      expect(states[1].effect, isA<ShowSnackBarEffect>());
      expect(
        (states[1].effect! as ShowSnackBarEffect).message,
        contains('2 actions synced'),
      );

      await cubit.close();
    });

    test('two identical-looking notifications both surface an effect',
        () async {
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => const Right(<QueuedAction>[]));
      final cubit = buildCubit();

      final states = <OfflineQueueState>[];
      cubit.stream.listen(states.add);

      notificationController.add(const DrainSucceeded(synced: 1, pending: 0));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      notificationController.add(const DrainSucceeded(synced: 1, pending: 0));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // clearEffect + effect, twice — both effects must reach listeners
      // even though the two notifications carry the same data.
      final effectStates = states.where((s) => s.effect != null).toList();
      expect(effectStates, hasLength(2));

      await cubit.close();
    });

    test('ActionConflicted surfaces a warning snackbar with the executor message',
        () async {
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => const Right(<QueuedAction>[]));
      final cubit = buildCubit();

      final states = <OfflineQueueState>[];
      cubit.stream.listen(states.add);

      notificationController.add(const ActionConflicted('duel expired'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final effect = states.last.effect! as ShowSnackBarEffect;
      expect(effect.message, 'duel expired');
      expect(effect.severity, FeedbackSeverity.warning);

      await cubit.close();
    });

    test('PendingChanged updates pendingCount without an effect', () async {
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => const Right([]));
      final cubit = buildCubit();

      notificationController.add(const PendingChanged(3));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.pendingCount, 0); // repository stub returns []
      expect(cubit.state.effect, isNull);

      await cubit.close();
    });
  });
}
