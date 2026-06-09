import 'package:health_duel/core/bloc/bloc.dart';

/// Navigate and replace entire stack
final class NavigateReplaceEffect extends NavigationEffect {

  NavigateReplaceEffect({
    required this.route,
    this.arguments,
  });
  final String route;
  final Object? arguments;

  @override
  List<Object?> get props => [...super.props, route, arguments];
}
