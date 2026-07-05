import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

sealed class FriendsState extends UiState with EffectClearable<FriendsState> {
  const FriendsState({super.effect});

  @override
  FriendsState clearEffect() => _copyWithEffect(null);

  @override
  FriendsState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  FriendsState _copyWithEffect(UiEffect? effect);
}

class FriendsInitial extends FriendsState {
  const FriendsInitial({super.effect});

  @override
  FriendsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  FriendsState _copyWithEffect(UiEffect? effect) => FriendsInitial(effect: effect);
}

class FriendsLoading extends FriendsState {
  const FriendsLoading({super.effect});

  @override
  FriendsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  FriendsState _copyWithEffect(UiEffect? effect) => FriendsLoading(effect: effect);
}

class FriendsLoaded extends FriendsState {
  final List<UserModel> friends;
  final List<UserModel> searchResults;
  final bool isSearching;
  final bool isMutating;

  const FriendsLoaded({
    required this.friends,
    this.searchResults = const [],
    this.isSearching = false,
    this.isMutating = false,
    super.effect,
  });

  @override
  List<Object?> get props => [friends, searchResults, isSearching, isMutating];

  @override
  FriendsState _copyWithEffect(UiEffect? effect) => FriendsLoaded(
        friends: friends,
        searchResults: searchResults,
        isSearching: isSearching,
        isMutating: isMutating,
        effect: effect,
      );

  FriendsLoaded copyWith({
    List<UserModel>? friends,
    List<UserModel>? searchResults,
    bool? isSearching,
    bool? isMutating,
    UiEffect? effect,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isMutating: isMutating ?? this.isMutating,
      effect: effect,
    );
  }
}

class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message, {super.effect});
  
  @override
  FriendsState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [message];

  @override
  FriendsState _copyWithEffect(UiEffect? effect) => FriendsError(message, effect: effect);
}
