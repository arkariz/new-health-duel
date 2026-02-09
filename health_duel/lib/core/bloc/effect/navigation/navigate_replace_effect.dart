import 'package:health_duel/core/bloc/bloc.dart';

/// Navigate and replace entire stack
final class NavigateReplaceEffect extends NavigationEffect {
  final String route;
  final Object? arguments;

  NavigateReplaceEffect({
    required this.route,
    this.arguments,
  });

  @override
  List<Object?> get props => [...super.props, route, arguments];
}