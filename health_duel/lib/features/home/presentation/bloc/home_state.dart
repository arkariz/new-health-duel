import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/session.dart';

/// Home feature status
enum HomeStatus {
  /// Initial state, waiting for data load
  initial,

  /// Loading userModel data
  loading,

  /// UserModel data loaded successfully
  loaded,

  /// Failed to load userModel data
  failure,
}

/// Home State - Pattern A: Single State with Clear Partitioning
///
/// Single immutable state class with clear separation between:
/// - Renderable data (included in props, triggers UI rebuild)
/// - Side-effect triggers (excluded from props, consumed once)
///
/// ═══════════════════════════════════════════════════════════════════
/// RENDERABLE DATA (UI displays these) - Included in [props]
/// ═══════════════════════════════════════════════════════════════════
/// - [status] - Current loading/error status
/// - [user] - Authenticated userModel data
/// - [errorMessage] - Error message to display
/// - [loadingMessage] - Optional loading message
///
/// ═══════════════════════════════════════════════════════════════════
/// SIDE-EFFECT TRIGGERS (consumed once, then cleared) - NOT in [props]
/// ═══════════════════════════════════════════════════════════════════
/// - [effect] - One-shot effects like navigation, snackbars
///
class HomeState extends UiState with EffectClearable<HomeState> {
  // ═══════════════════════════════════════════════════════════════════
  // RENDERABLE DATA
  // ═══════════════════════════════════════════════════════════════════

  /// Current status of home feature
  final HomeStatus status;

  /// Authenticated userModel (null when not loaded or error)
  final UserModel? user;

  /// Error message when status is failure
  final String? errorMessage;

  /// Optional loading message
  final String? loadingMessage;

  // ═══════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════════

  const HomeState({this.status = HomeStatus.initial, this.user, this.errorMessage, this.loadingMessage, super.effect});

  // ═══════════════════════════════════════════════════════════════════
  // EQUATABLE - Only renderable data, NOT effect
  // ═══════════════════════════════════════════════════════════════════

  @override
  List<Object?> get props => [status, user, errorMessage, loadingMessage];

  // ═══════════════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════════════

  HomeState copyWith({
    HomeStatus? status,
    UserModel? user,
    String? errorMessage,
    String? loadingMessage,
    UiEffect? effect,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadingMessage: loadingMessage ?? this.loadingMessage,
      effect: effect,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EFFECT CLEARABLE IMPLEMENTATION
  // ═══════════════════════════════════════════════════════════════════

  @override
  HomeState clearEffect() => copyWith();

  @override
  HomeState withEffect(UiEffect? effect) => copyWith(effect: effect);

  // ═══════════════════════════════════════════════════════════════════
  // CONVENIENCE GETTERS
  // ═══════════════════════════════════════════════════════════════════

  bool get isInitial => status == HomeStatus.initial;
  bool get isLoading => status == HomeStatus.loading;
  bool get isLoaded => status == HomeStatus.loaded;
  bool get isFailure => status == HomeStatus.failure;
  bool get hasUserModel => user != null;
}
