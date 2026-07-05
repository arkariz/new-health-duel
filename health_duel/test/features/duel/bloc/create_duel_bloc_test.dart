import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockGetFriends mockGetFriends;
  late MockGetOpponents mockGetOpponents;
  late MockCreateDuel mockCreateDuel;
  late MockSessionRepository mockSessionRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockGetFriends = MockGetFriends();
    mockGetOpponents = MockGetOpponents();
    mockCreateDuel = MockCreateDuel();
    mockSessionRepository = MockSessionRepository();
  });

  CreateDuelBloc buildBloc() => CreateDuelBloc(
        getFriends: mockGetFriends,
        getOpponents: mockGetOpponents,
        createDuel: mockCreateDuel,
        sessionRepository: mockSessionRepository,
      );

  group('CreateDuelBloc', () {
    test('initial state is CreateDuelInitial', () {
      expect(buildBloc().state, const CreateDuelInitial());
    });

    // ─── CreateDuelOpponentsRequested ──────────────────────────────────────
    group('CreateDuelOpponentsRequested', () {
      const currentUserId = 'test-user-123';

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [LoadingOpponents, Ready] using GetFriends by default (friends source)',
        build: () {
          mockGetFriends.setupSuccess(
            currentUserId,
            [tOpponentModel, tOpponent2Model],
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const CreateDuelOpponentsRequested(currentUserId)),
        expect: () => [
          const CreateDuelLoadingOpponents(),
          isA<CreateDuelReady>().having(
            (s) => s.opponents,
            'opponents',
            [tOpponentModel, tOpponent2Model],
          ),
        ],
        verify: (_) {
          verify(() => mockGetFriends(currentUserId)).called(1);
          verifyNever(() => mockGetOpponents(any()));
        },
      );

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [LoadingOpponents, Failure] with error effect when friends fetch fails',
        build: () {
          mockGetFriends.setupFailure(
            currentUserId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const CreateDuelOpponentsRequested(currentUserId)),
        expect: () => [
          const CreateDuelLoadingOpponents(),
          isA<CreateDuelFailure>()
              .having((s) => s.message, 'message', tDuelErrorMessage)
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [LoadingOpponents, Ready] using GetOpponents when source is all',
        build: () {
          mockGetOpponents.setupSuccess(
            currentUserId,
            [tOpponentModel, tOpponent2Model],
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CreateDuelOpponentsRequested(
          currentUserId,
          source: OpponentSource.all,
        )),
        expect: () => [
          const CreateDuelLoadingOpponents(),
          isA<CreateDuelReady>().having(
            (s) => s.opponents,
            'opponents',
            [tOpponentModel, tOpponent2Model],
          ),
        ],
        verify: (_) {
          verify(() => mockGetOpponents(currentUserId)).called(1);
          verifyNever(() => mockGetFriends(any()));
        },
      );

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [LoadingOpponents, Failure] with error effect when all-players fetch fails',
        build: () {
          mockGetOpponents.setupFailure(
            currentUserId,
            const ServerFailure(message: tDuelErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const CreateDuelOpponentsRequested(
          currentUserId,
          source: OpponentSource.all,
        )),
        expect: () => [
          const CreateDuelLoadingOpponents(),
          isA<CreateDuelFailure>()
              .having((s) => s.message, 'message', tDuelErrorMessage)
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );
    });

    // ─── CreateDuelSubmitted ───────────────────────────────────────────────
    group('CreateDuelSubmitted', () {
      const challengerId = 'test-user-123';
      const challengerName = 'Test User';
      const challengedId = 'opponent-user-456';
      const challengedName = 'Opponent User';

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [Submitting, Success] with success effect on successful creation',
        build: () {
          mockGetFriends.setupSuccess(challengerId, [tOpponentModel]);
          mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
          mockCreateDuel.setupSuccess(
            challengerId: challengerId,
            challengedId: challengedId,
            challengerName: challengerName,
            challengedName: challengedName,
            result: tPendingDuel,
          );
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const CreateDuelOpponentsRequested(challengerId));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(const CreateDuelSubmitted(
            challengerId: challengerId,
            challengedId: challengedId,
            challengedName: challengedName,
          ));
        },
        skip: 2, // skip LoadingOpponents and Ready
        expect: () => [
          isA<CreateDuelSubmitting>(),
          isA<CreateDuelSuccess>()
              .having((s) => s.duel.id, 'duel.id', tPendingDuelId)
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits [Submitting, Failure] with error effect when creation fails',
        build: () {
          mockGetFriends.setupSuccess(challengerId, [tOpponentModel]);
          mockSessionRepository.setupGetCurrentUserDuel(tUserModel);
          mockCreateDuel.setupFailure(
            challengerId: challengerId,
            challengedId: challengedId,
            challengerName: challengerName,
            challengedName: challengedName,
            failure: const ValidationFailure(
              message: 'You already have an active duel with this user',
            ),
          );
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const CreateDuelOpponentsRequested(challengerId));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(const CreateDuelSubmitted(
            challengerId: challengerId,
            challengedId: challengedId,
            challengedName: challengedName,
          ));
        },
        skip: 2,
        expect: () => [
          isA<CreateDuelSubmitting>(),
          isA<CreateDuelFailure>()
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );

      blocTest<CreateDuelBloc, CreateDuelState>(
        'emits Failure when session user is null (unauthenticated)',
        build: () {
          mockGetFriends.setupSuccess(challengerId, [tOpponentModel]);
          when(() => mockSessionRepository.getCurrentUser())
              .thenAnswer((_) async => const Right(null));
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const CreateDuelOpponentsRequested(challengerId));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(const CreateDuelSubmitted(
            challengerId: challengerId,
            challengedId: challengedId,
            challengedName: challengedName,
          ));
        },
        skip: 2,
        expect: () => [
          isA<CreateDuelSubmitting>(),
          isA<CreateDuelFailure>()
              .having(
                (s) => s.message,
                'message',
                contains('Unable to get user info'),
              )
              .having((s) => s.effect, 'effect', isA<ShowSnackBarEffect>()),
        ],
      );
    });
  });
}
