import 'package:health_duel/core/bloc/bloc.dart';

final class NavigatePushEffect extends NavigationEffect {

  NavigatePushEffect({
    required this.route,
    this.arguments,
  });
  final String route;
  final Object? arguments;

  @override
  List<Object?> get props => [...super.props, route, arguments];
}
