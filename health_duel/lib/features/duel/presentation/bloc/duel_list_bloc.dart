import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/duel/domain/domain.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

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
  DuelListBloc({
    required GetActiveDuels getActiveDuels,
    required GetPendingDuels getPendingDuels,
    required GetSentDuels getSentDuels,
    required GetDuelHistory getDuelHistory,
    required AcceptDuel acceptDuel,
    required DeclineDuel declineDuel,
    required SyncHealthData syncHealthData,
    required CheckHealthPermissions checkHealthPermissions,
    required CompleteDuel completeDuel,
  })  : _getActiveDuels = getActiveDuels,
        _getPendingDuels = getPendingDuels,
        _getSentDuels = getSentDuels,
        _getDuelHistory = getDuelHistory,
        _acceptDuel = acceptDuel,
        _declineDuel = declineDuel,
        _syncHealthData = syncHealthData,
        _checkHealthPermissions = checkHealthPermissions,
        _completeDuel = completeDuel,
        super(const DuelListInitial()) {
    on<DuelListLoadRequested>(_onLoadRequested);
    on<DuelAcceptRequested>(_onAcceptRequested);
    on<DuelDeclineRequested>(_onDeclineRequested);
  }
  final GetActiveDuels _getActiveDuels;
  final GetPendingDuels _getPendingDuels;
  final GetSentDuels _getSentDuels;
  final GetDuelHistory _getDuelHistory;
  final AcceptDuel _acceptDuel;
  final DeclineDuel _declineDuel;
  final SyncHealthData _syncHealthData;
  final CheckHealthPermissions _checkHealthPermissions;
  final CompleteDuel _completeDuel;

  Future<void> _onLoadRequested(
    DuelListLoadRequested event,
    Emitter<DuelListState> emit,
  ) async {
    emit(const DuelListLoading());

    // Fetch all four lists in parallel
    final results = await Future.wait([
      _getActiveDuels(event.userId),
      _getPendingDuels(event.userId),
      _getSentDuels(event.userId),
      _getDuelHistory(event.userId),
    ]);

    final activeResult = results[0];
    final pendingResult = results[1];
    final sentResult = results[2];
    final historyResult = results[3];

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
    if (sentResult.isLeft()) {
      emit(DuelListError(
        sentResult.fold((f) => f.message, (_) => 'Failed to load duels'),
      ));
      return;
    }
    if (historyResult.isLeft()) {
      emit(DuelListError(
        historyResult.fold((f) => f.message, (_) => 'Failed to load duels'),
      ));
      return;
    }

    var activeList = activeResult.getOrElse(() => []);
    var historyList = historyResult.getOrElse(() => []);

    // Sweep: finalize expired duels still marked active in Firestore so
    // they move to History even if the duel screen is never opened.
    final expired = activeList.where((d) => d.needsCompletion).toList();
    if (expired.isNotEmpty) {
      for (final duel in expired) {
        // Failures are non-fatal — the duel stays in Active until next load
        await _completeDuel(duel.id);
      }
      final refreshedActive = await _getActiveDuels(event.userId);
      final refreshedHistory = await _getDuelHistory(event.userId);
      activeList = refreshedActive.getOrElse(() => activeList);
      historyList = refreshedHistory.getOrElse(() => historyList);
    }

    emit(DuelListLoaded(
      activeDuels: activeList,
      pendingDuels: pendingResult.getOrElse(() => []),
      sentDuels: sentResult.getOrElse(() => []),
      historyDuels: historyList,
    ));

    // Background health sync — only if permissions are already granted
    // so the home screen reflects fresh step counts without extra dialogs.
    if (activeList.isNotEmpty) {
      final permResult = await _checkHealthPermissions();
      final isAuthorized = permResult.fold(
        (_) => false,
        (status) => status == HealthPermissionStatus.authorized,
      );

      if (isAuthorized) {
        await Future.wait(
          activeList.map(
            (duel) => _syncHealthData(duelId: duel.id, userId: event.userId),
          ),
        );

        final refreshedResult = await _getActiveDuels(event.userId);
        refreshedResult.fold(
          (_) {},
          (refreshed) {
            if (state is DuelListLoaded) {
              emit((state as DuelListLoaded).copyWith(activeDuels: refreshed));
            }
          },
        );
      }
    }
  }

  Future<void> _onAcceptRequested(
    DuelAcceptRequested event,
    Emitter<DuelListState> emit,
  ) async {
    final result = await _acceptDuel(event.duelId);

    result.fold(
      (failure) {
        if (state is DuelListLoaded) {
          emitWithEffect(
            emit,
            state,
            _effectError(failure.message),
          );
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
          final isCancel =
              current.sentDuels.any((d) => d.id == event.duelId);
          emit(current.copyWith(
            pendingDuels: current.pendingDuels
                .where((d) => d.id != event.duelId)
                .toList(),
            sentDuels: current.sentDuels
                .where((d) => d.id != event.duelId)
                .toList(),
            effect:
                isCancel ? _effectCancelSuccess() : _effectDeclineSuccess(),
          ));
        }
      },
    );
  }
}
