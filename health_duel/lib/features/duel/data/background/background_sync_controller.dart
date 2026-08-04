import 'package:workmanager/workmanager.dart';

/// Registers/cancels the periodic background step-sync task.
///
/// Abstracted behind an interface so `DuelBloc` stays unit-testable with a
/// mock, without touching the real `workmanager` plugin (which requires
/// platform channels unavailable under `flutter_test`).
abstract class BackgroundSyncController {
  Future<void> register({required String duelId});
  Future<void> cancel();
}

class WorkmanagerBackgroundSyncController implements BackgroundSyncController {
  static const uniqueName = 'health_duel_step_sync';
  static const taskName = 'stepSyncTask';

  @override
  Future<void> register({required String duelId}) {
    return Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      // Android enforces a 15-minute floor for periodic work; iOS timing is
      // opportunistic (Background App Refresh) regardless of what's passed.
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  @override
  Future<void> cancel() {
    return Workmanager().cancelByUniqueName(uniqueName);
  }
}
