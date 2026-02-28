import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';

part 'duel_list_side_effect.dart';

/// DuelList BLoC — Manages Active / Pending / History duel lists
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004).
///
/// State flow:
/// - [DuelListInitial] → initial
/// - [DuelListLoading] → fetching all three lists in parallel
/// - [DuelListLoaded]  → all lists fetched (any can be empty)
/// - [DuelListError]   → failed to fetch
class DuelListBloc extends EffectBloc<DuelListEvent, DuelListState> {
  final GetActiveDuels _getActiveDuels;
  final GetPendingDuels _getPendingDuels;
  final GetDuelHistory _getDuelHistory;
  final AcceptDuel _acceptDuel;
  final DeclineDuel _declineDuel;

  DuelListBloc({
    required GetActiveDuels getActiveDuels,
    required GetPendingDuels getPendingDuels,
    required GetDuelHistory getDuelHistory,
    required AcceptDuel acceptDuel,
    required DeclineDuel declineDuel,
  })  : _getActiveDuels = getActiveDuels,
        _getPendingDuels = getPendingDuels,
        _getDuelHistory = getDuelHistory,
        _acceptDuel = acceptDuel,
        _declineDuel = declineDuel,
        super(const DuelListInitial()) {
    on<DuelListLoadRequested>(_onLoadRequested);
    on<DuelAcceptRequested>(_onAcceptRequested);
    on<DuelDeclineRequested>(_onDeclineRequested);
  }

  Future<void> _onLoadRequested(
    DuelListLoadRequested event,
    Emitter<DuelListState> emit,
  ) async {
    emit(const DuelListLoading());

    // Fetch all three lists in parallel
    final results = await Future.wait([
      _getActiveDuels(event.userId),
      _getPendingDuels(event.userId),
      _getDuelHistory(event.userId),
    ]);

    final activeResult = results[0];
    final pendingResult = results[1];
    final historyResult = results[2];

    // Fail fast if any list errors
    if (activeResult.isLeft()) {
      emit(DuelListError(
        activeResult.fold((f) => f.message, (_) => 'Failed to load duels'),
      ));
      return;
    }
    if (pendingResult.isLeft()) {
      emit(DuelListError(
        pendingResult.fold((f) => f.message, (_) => 'Failed to load duels'),
      ));
      return;
    }
    if (historyResult.isLeft()) {
      emit(DuelListError(
        historyResult.fold((f) => f.message, (_) => 'Failed to load duels'),
      ));
      return;
    }

    emit(DuelListLoaded(
      activeDuels: activeResult.getOrElse(() => []),
      pendingDuels: pendingResult.getOrElse(() => []),
      historyDuels: historyResult.getOrElse(() => []),
    ));
  }

  Future<void> _onAcceptRequested(
    DuelAcceptRequested event,
    Emitter<DuelListState> emit,
  ) async {
    final result = await _acceptDuel(event.duelId);

    result.fold(
      (failure) {
        if (state is DuelListLoaded) {
          emit((state as DuelListLoaded).copyWith(
            effect: _effectError(failure.message),
          ));
        }
      },
      (duel) {
        if (state is DuelListLoaded) {
          final current = state as DuelListLoaded;
          emit(current.copyWith(
            activeDuels: [duel, ...current.activeDuels],
            pendingDuels: current.pendingDuels
                .where((d) => d.id != event.duelId)
                .toList(),
            effect: _effectAcceptSuccess(),
          ));
        }
      },
    );
  }

  Future<void> _onDeclineRequested(
    DuelDeclineRequested event,
    Emitter<DuelListState> emit,
  ) async {
    final result = await _declineDuel(event.duelId);

    result.fold(
      (failure) {
        if (state is DuelListLoaded) {
          emit((state as DuelListLoaded).copyWith(
            effect: _effectError(failure.message),
          ));
        }
      },
      (_) {
        if (state is DuelListLoaded) {
          final current = state as DuelListLoaded;
          emit(current.copyWith(
            pendingDuels: current.pendingDuels
                .where((d) => d.id != event.duelId)
                .toList(),
            effect: _effectDeclineSuccess(),
          ));
        }
      },
    );
  }
}
