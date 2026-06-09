/// Converts Stream to ChangeNotifier for GoRouter refresh
///
/// Usage: `refreshListenable: GoRouterRefreshStream(bloc.stream)`
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies GoRouter to refresh when stream emits
class GoRouterRefreshStream extends ChangeNotifier {

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
