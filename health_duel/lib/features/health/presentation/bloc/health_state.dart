import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';


/// Design Rationale:
/// - Clean Architecture: Domain drives presentation state
/// - No duplication: HealthPermissionStatus already covers all cases
/// - Simpler: UI derives view from permission status + flags
///
/// State Composition:
/// - [isLoading] - Initial load indicator
/// - [isAuthorized] - Whether permission is granted
/// - [isRefreshing] - Background refresh indicator
/// - [todaySteps] - Data (retained during refresh)
class HealthState extends UiState with EffectClearable<HealthState> {

  /// Today's step count (nullable until first successful fetch)
  final StepCount? todaySteps;

  /// Whether initial load is in progress
  final bool isLoading;

  final bool isAuthorized;

  /// Whether this is a background refresh (keep showing previous data)
  final bool isRefreshing;

  const HealthState({
    this.todaySteps,
    this.isLoading = true,
    this.isAuthorized = false,
    this.isRefreshing = false,
    super.effect,
  });

  /// Initial state factory
  factory HealthState.initial() => const HealthState();

  @override
  List<Object?> get props => [
    todaySteps,
    isLoading,
    isAuthorized,
    isRefreshing,
    // Note: effect excluded from props to prevent UI rebuild on effect clear
  ];

  /// CopyWith for state updates
  HealthState copyWith({
    StepCount? todaySteps,
    bool? isLoading,
    bool? isAuthorized,
    bool? isRefreshing,
    UiEffect? effect,
  }) {
    return HealthState(
      todaySteps: todaySteps ?? this.todaySteps,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      effect: effect ?? this.effect,
    );
  }

  @override
  HealthState clearEffect() => copyWith(effect: null);

  @override
  HealthState withEffect(UiEffect? effect) => copyWith(effect: effect);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE TRANSITION METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Transition to loading state
  HealthState toLoading() => copyWith(isLoading: true);

  /// Transition to refreshing state (keep existing data)
  HealthState toRefreshing() => copyWith(isRefreshing: true);

  /// Stop loading/refreshing
  HealthState stopLoading() => copyWith(isLoading: false, isRefreshing: false);

  /// Update permission status
  HealthState setAuthorization(bool authorized) => copyWith(isAuthorized: authorized, isLoading: false);

  /// Transition to ready state with step data
  HealthState toReady(StepCount stepCount) => copyWith(
    todaySteps: stepCount,
    isLoading: false,
    isRefreshing: false,
  );

  /// Reset to initial state
  HealthState toInitial({UiEffect? effect}) => HealthState.initial().copyWith(effect: effect);

  // ═══════════════════════════════════════════════════════════════════════════
  // UI VIEW GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Whether we have step data
  bool get hasStepData => todaySteps != null;

  /// Show permission view (notDetermined or denied)
  bool get showPermissionRequired => !isAuthorized;

  /// Show step counter (authorized + has data)
  bool get showReady => isAuthorized && hasStepData;

  /// Whether step data contains manual entries
  bool get hasManualEntries => todaySteps?.hasManualEntries ?? false;
}
