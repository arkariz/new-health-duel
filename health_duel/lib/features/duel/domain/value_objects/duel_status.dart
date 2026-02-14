/// Duel Status Value Object
///
/// Represents the current state of a duel in its lifecycle.
enum DuelStatus {
  /// Challenge sent, awaiting acceptance by challenged user
  pending,

  /// Both users accepted, competition in progress (24-hour window)
  active,

  /// 24-hour window ended, winner/loser/tie determined
  completed,

  /// User cancelled challenge before it was accepted
  cancelled,

  /// Pending invitation expired (24 hours without acceptance)
  expired;

  /// Check if duel can be accepted
  bool get canBeAccepted => this == DuelStatus.pending;

  /// Check if duel can be cancelled
  bool get canBeCancelled => this == DuelStatus.pending;

  /// Check if duel is currently in progress
  bool get isInProgress => this == DuelStatus.active;

  /// Check if duel is in final state (no further actions possible)
  bool get isFinal =>
      this == DuelStatus.completed ||
      this == DuelStatus.cancelled ||
      this == DuelStatus.expired;
}
