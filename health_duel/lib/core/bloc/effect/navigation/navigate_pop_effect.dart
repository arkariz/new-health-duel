import 'package:health_duel/core/bloc/bloc.dart';

final class NavigatePopEffect extends NavigationEffect {

  NavigatePopEffect({this.result});
  final Object? result;

  @override
  List<Object?> get props => [...super.props, result];
}
