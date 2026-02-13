import 'package:equatable/equatable.dart';

/// Home Events - Commands that can be dispatched to HomeBloc
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load/refresh current user data
class HomeLoadUserRequested extends HomeEvent {
  const HomeLoadUserRequested();
}

/// Request to sign out the current user
class HomeSignOutRequested extends HomeEvent {
  const HomeSignOutRequested();
}

/// Request to refresh user data (pull-to-refresh)
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Request to navigate to health feature
class HomeNavigateToHealthRequested extends HomeEvent {
  const HomeNavigateToHealthRequested();
}
