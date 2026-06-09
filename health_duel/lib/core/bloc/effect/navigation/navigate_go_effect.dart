import 'package:health_duel/core/bloc/bloc.dart';

final class NavigateGoEffect extends NavigationEffect {

  NavigateGoEffect({
    required this.route,
    this.arguments,
    this.queryParameters,
  });
  final String route;
  final Object? arguments;
  final Map<String, String>? queryParameters;

  @override
  List<Object?> get props => [...super.props, route, arguments, queryParameters];
}
