import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

sealed class SettingsState extends UiState with EffectClearable<SettingsState> {
  const SettingsState({super.effect});

  @override
  SettingsState clearEffect() => _copyWithEffect(null);

  @override
  SettingsState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  SettingsState _copyWithEffect(UiEffect? effect);
}

class SettingsInitial extends SettingsState {
  const SettingsInitial({super.effect});

  @override
  SettingsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  SettingsState _copyWithEffect(UiEffect? effect) => SettingsInitial(effect: effect);
}

class SettingsLoading extends SettingsState {
  const SettingsLoading({super.effect});

  @override
  SettingsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  SettingsState _copyWithEffect(UiEffect? effect) => SettingsLoading(effect: effect);
}

class SettingsLoaded extends SettingsState {

  const SettingsLoaded({
    required this.user,
    required this.requiresPasswordReauth,
    this.isSigningOut = false,
    this.isDeleting = false,
    super.effect,
  });

  final UserModel user;
  final bool requiresPasswordReauth;
  final bool isSigningOut;
  final bool isDeleting;

  @override
  List<Object?> get props => [user, requiresPasswordReauth, isSigningOut, isDeleting];

  @override
  SettingsState _copyWithEffect(UiEffect? effect) => SettingsLoaded(
        user: user,
        requiresPasswordReauth: requiresPasswordReauth,
        isSigningOut: isSigningOut,
        isDeleting: isDeleting,
        effect: effect,
      );

  @override
  SettingsLoaded copyWith({
    UserModel? user,
    bool? requiresPasswordReauth,
    bool? isSigningOut,
    bool? isDeleting,
    UiEffect? effect,
  }) {
    return SettingsLoaded(
      user: user ?? this.user,
      requiresPasswordReauth: requiresPasswordReauth ?? this.requiresPasswordReauth,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isDeleting: isDeleting ?? this.isDeleting,
      effect: effect,
    );
  }
}

class SettingsError extends SettingsState {
  const SettingsError(this.message, {super.effect});
  final String message;

  @override
  SettingsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [message];

  @override
  SettingsState _copyWithEffect(UiEffect? effect) => SettingsError(message, effect: effect);
}
