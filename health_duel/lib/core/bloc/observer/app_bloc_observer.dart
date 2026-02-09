/// Debug observer for all Blocs
///
/// Logs events, state transitions, and errors.
/// Only active in debug mode.
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global BLoC observer for debugging and analytics
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _log('🟢 onCreate', bloc.runtimeType.toString());
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _log(
      '📩 onEvent',
      '${bloc.runtimeType} ← ${event.runtimeType}',
      details: event.toString(),
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log(
      '🔄 onChange',
      bloc.runtimeType.toString(),
      details: '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _log(
      '➡️ onTransition',
      bloc.runtimeType.toString(),
      details: [
        'Event: ${transition.event.runtimeType}',
        'From: ${transition.currentState.runtimeType}',
        'To: ${transition.nextState.runtimeType}',
      ].join('\n'),
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _log(
      '❌ onError',
      bloc.runtimeType.toString(),
      details: error.toString(),
      isError: true,
    );
    if (kDebugMode) {
      developer.log(
        stackTrace.toString(),
        name: 'BlocObserver',
        level: 1000, // Severe
      );
    }
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _log('🔴 onClose', bloc.runtimeType.toString());
  }

  void _log(
    String action,
    String bloc, {
    String? details,
    bool isError = false,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('$action: $bloc')
      ..write(details != null ? '  $details' : '');

    developer.log(
      buffer.toString(),
      name: 'BlocObserver',
      level: isError ? 1000 : 800,
    );
  }
}
