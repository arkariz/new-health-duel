import 'dart:async';

import 'package:flutter/foundation.dart';

/// Debouncer utility for delaying actions until input stops
///
/// Useful for real-time form validation, search-as-you-type, etc.
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 300);
///
/// void onSearchChanged(String query) {
///   _debouncer.run(() {
///     // Perform search after user stops typing
///   });
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  /// Create a debouncer with optional delay in milliseconds
  Debouncer({this.milliseconds = 300});

  /// Delay in milliseconds before action is executed
  final int milliseconds;

  Timer? _timer;

  /// Run the action after the debounce delay
  ///
  /// If called again before the delay expires, the previous
  /// action is cancelled and the timer restarts.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Check if there's a pending action
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose the debouncer and cancel any pending action
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
