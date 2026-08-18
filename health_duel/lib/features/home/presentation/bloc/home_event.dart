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

/// Request to refresh user data (pull-to-refresh)
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}
