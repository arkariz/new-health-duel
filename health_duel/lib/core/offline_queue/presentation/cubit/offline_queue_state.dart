import 'package:health_duel/core/bloc/bloc.dart';

/// State for the app-wide `OfflineQueueCubit` (ADR-006).
///
/// Single concrete state (not sealed like feature blocs) — this cubit only
/// ever tracks a pending count and an optional one-shot snackbar effect, it
/// has no loading/error phases of its own.
class OfflineQueueState extends UiState with EffectClearable<OfflineQueueState> {
  const OfflineQueueState({this.pendingCount = 0, super.effect});

  final int pendingCount;

  @override
  List<Object?> get props => [pendingCount];

  @override
  OfflineQueueState clearEffect() => _copyWithEffect(null);

  @override
  OfflineQueueState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  @override
  OfflineQueueState copyWith({int? pendingCount, UiEffect? effect}) =>
      OfflineQueueState(
        pendingCount: pendingCount ?? this.pendingCount,
        effect: effect,
      );

  OfflineQueueState _copyWithEffect(UiEffect? effect) => OfflineQueueState(
        pendingCount: pendingCount,
        effect: effect,
      );
}
