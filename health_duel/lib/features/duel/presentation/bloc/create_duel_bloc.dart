import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_state.dart';

part 'create_duel_side_effect.dart';

/// Create Duel BLoC — Handles opponent loading and duel submission
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004).
///
/// State flow:
/// - [CreateDuelInitial]          → before anything
/// - [CreateDuelLoadingOpponents] → fetching user list from Firestore
/// - [CreateDuelReady]            → opponents loaded, form ready
/// - [CreateDuelSubmitting]       → awaiting Firestore write
/// - [CreateDuelSuccess]          → duel created; screen pops
/// - [CreateDuelFailure]          → loading or creation failed
class CreateDuelBloc extends EffectBloc<CreateDuelEvent, CreateDuelState> {
  final GetOpponents _getOpponents;
  final CreateDuel _createDuel;
  final SessionRepository _sessionRepository;

  CreateDuelBloc({
    required GetOpponents getOpponents,
    required CreateDuel createDuel,
    required SessionRepository sessionRepository,
  })  : _getOpponents = getOpponents,
        _createDuel = createDuel,
        _sessionRepository = sessionRepository,
        super(const CreateDuelInitial()) {
    on<CreateDuelOpponentsRequested>(_onOpponentsRequested);
    on<CreateDuelSubmitted>(_onSubmitted);
  }

  Future<void> _onOpponentsRequested(
    CreateDuelOpponentsRequested event,
    Emitter<CreateDuelState> emit,
  ) async {
    emit(const CreateDuelLoadingOpponents());

    final result = await _getOpponents(event.currentUserId);

    result.fold(
      (failure) => emit(CreateDuelFailure(
        failure.message,
        effect: _effectError(failure.message),
      )),
      (opponents) => emit(CreateDuelReady(opponents: opponents)),
    );
  }

  Future<void> _onSubmitted(
    CreateDuelSubmitted event,
    Emitter<CreateDuelState> emit,
  ) async {
    // Carry opponents list forward so UI doesn't lose them
    final currentOpponents = state is CreateDuelReady
        ? (state as CreateDuelReady).opponents
        : <dynamic>[];

    emit(CreateDuelSubmitting(opponents: List.from(currentOpponents)));

    // Fetch challenger name from session
    final userResult = await _sessionRepository.getCurrentUser();
    final challengerName = userResult.fold((_) => null, (u) => u?.name);

    if (challengerName == null) {
      emit(CreateDuelFailure(
        'Unable to get user info. Please try again.',
        effect: _effectError('Unable to get user info. Please try again.'),
      ));
      return;
    }

    final result = await _createDuel(
      challengerId: event.challengerId,
      challengedId: event.challengedId,
      challengerName: challengerName,
      challengedName: event.challengedName,
    );

    result.fold(
      (failure) => emit(CreateDuelFailure(
        failure.message,
        effect: _effectError(failure.message),
      )),
      (duel) => emit(CreateDuelSuccess(duel, effect: _effectSuccess())),
    );
  }
}
