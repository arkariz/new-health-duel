import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_cubit.dart';
import 'connectivity_state.dart';

/// Extension to easily check connectivity from BuildContext
///
/// Usage:
/// ```dart
/// if (context.isOnline) {
///   // Make network request
/// } else {
///   // Show offline message
/// }
/// ```
extension ConnectivityContext on BuildContext {
  /// Check if device is online
  bool get isOnline => read<ConnectivityCubit>().state == ConnectivityStatus.online;

  /// Check if device is offline
  bool get isOffline => read<ConnectivityCubit>().state == ConnectivityStatus.offline;

  /// Get current connectivity status
  ConnectivityStatus get connectivityStatus => read<ConnectivityCubit>().state;

  /// Watch connectivity status (rebuilds on change)
  ConnectivityStatus watchConnectivity() => watch<ConnectivityCubit>().state;
}
