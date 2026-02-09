import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_state.dart';

/// Cubit for tracking device connectivity status
///
/// Usage:
/// ```dart
/// // In DI
/// getIt.registerLazySingleton<ConnectivityCubit>(
///   () => ConnectivityCubit(Connectivity())..init(),
/// );
///
/// // In widget tree (usually at app root)
/// BlocProvider.value(
///   value: getIt<ConnectivityCubit>(),
///   child: ...
/// )
///
/// // Listen for changes
/// BlocListener<ConnectivityCubit, ConnectivityStatus>(
///   listener: (context, status) {
///     if (status == ConnectivityStatus.offline) {
///       // Show offline banner
///     }
///   },
/// )
/// ```
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(this._connectivity) : super(ConnectivityStatus.unknown);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize and start listening for connectivity changes
  Future<void> init() async {
    // Get initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      emit(ConnectivityStatus.offline);
    } else {
      emit(ConnectivityStatus.online);
    }
  }

  /// Check if currently online
  bool get isOnline => state == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => state == ConnectivityStatus.offline;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
