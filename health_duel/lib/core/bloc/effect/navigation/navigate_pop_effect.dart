import 'package:health_duel/core/bloc/bloc.dart';

final class NavigatePopEffect extends NavigationEffect {
  final Object? result;

  NavigatePopEffect({this.result});

  @override
  List<Object?> get props => [...super.props, result];
}