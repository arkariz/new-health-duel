/// Duel Metric Value Object
///
/// What a duel or solo challenge is measured by. Only [steps] is
/// selectable in v1 — `distance` and `activeMinutes` are defined now so
/// the `challengerValue`/`challengedValue` field rename (done alongside
/// this) never has to happen again once a second metric ships.
enum DuelMetric {
  steps(
    unit: 'steps',
    displayName: 'Steps',
    supportsHeadToHead: true,
  ),
  distance(
    unit: 'km',
    displayName: 'Distance',
    supportsHeadToHead: true,
  ),
  activeMinutes(
    unit: 'min',
    displayName: 'Active Minutes',
    supportsHeadToHead: true,
  );

  const DuelMetric({
    required this.unit,
    required this.displayName,
    required this.supportsHeadToHead,
  });

  final String unit;
  final String displayName;

  /// Whether this metric is fair to compare between two different bodies.
  /// See the MVP plan's metric evaluation table (§Metrics) — a metric
  /// like active-calories is solo-only precisely because this is false.
  final bool supportsHeadToHead;
}
