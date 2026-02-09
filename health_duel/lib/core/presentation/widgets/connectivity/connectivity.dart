/// Connectivity tracking module
///
/// Provides connectivity state management and UI widgets for
/// displaying offline status to users.
///
/// ## Usage
///
/// 1. Register in DI:
/// ```dart
/// getIt.registerLazySingleton<ConnectivityCubit>(
///   () => ConnectivityCubit(Connectivity())..init(),
/// );
/// ```
///
/// 2. Provide in widget tree:
/// ```dart
/// BlocProvider.value(
///   value: getIt<ConnectivityCubit>(),
///   child: MaterialApp(...),
/// )
/// ```
///
/// 3. Use widgets:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const AnimatedOfflineBanner(),
///       Expanded(child: content),
///     ],
///   ),
/// )
/// ```
///
/// 4. Check status in code:
/// ```dart
/// if (context.isOnline) {
///   // Make network request
/// }
/// ```
library;

export 'connectivity_cubit.dart';
export 'connectivity_extensions.dart';
export 'connectivity_state.dart';
export 'connectivity_widgets.dart';
