import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:health/health.dart';
import 'package:health_duel/core/config/firebase_options.dart';
import 'package:health_duel/features/duel/data/background/active_duel_pointer.dart';
import 'package:health_duel/features/duel/data/datasources/duel_firestore_datasource.dart';
import 'package:health_duel/features/duel/data/repositories/duel_repository_impl.dart';
import 'package:health_duel/features/duel/domain/usecases/sync_health_data.dart';
import 'package:health_duel/features/health/data/datasources/health_platform_data_source.dart';
import 'package:health_duel/features/health/data/repositories/health_repository_impl.dart';
import 'package:workmanager/workmanager.dart';

/// Entry point invoked by the OS in a separate background isolate — no
/// access to the main isolate's GetIt container, so [HealthSyncBackgroundHandler]
/// rebuilds the minimal dependency graph it needs by hand.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await HealthSyncBackgroundHandler().run();
    } on Exception {
      // Best-effort, same as the foreground sync — never surface a failure
      // to the user or trigger aggressive OS retries.
    }
    return true;
  });
}

/// Rebuilds and runs [SyncHealthData] outside of GetIt/the main isolate.
///
/// Constructor parameters are injection seams for unit testing — the real
/// `workmanager`/`Firebase.initializeApp` plumbing itself cannot run under
/// `flutter_test` and must be verified manually on-device.
class HealthSyncBackgroundHandler {
  HealthSyncBackgroundHandler({
    Future<void> Function()? firebaseInit,
    ActiveDuelPointer? pointer,
    SyncHealthData? syncHealthData,
  })  : _firebaseInit = firebaseInit,
        _pointer = pointer ?? ActiveDuelPointerImpl(),
        _syncHealthData = syncHealthData;

  final Future<void> Function()? _firebaseInit;
  final ActiveDuelPointer _pointer;
  final SyncHealthData? _syncHealthData;

  Future<void> run() async {
    await (_firebaseInit ?? _defaultFirebaseInit)();

    final activeDuel = await _pointer.read();
    if (activeDuel == null) return; // No active duel — nothing to sync.

    final sync = _syncHealthData ?? _buildSyncHealthData();
    final result = await sync(
      duelId: activeDuel.duelId,
      userId: activeDuel.userId,
    );
    // Silent best-effort, consistent with the foreground sync path.
    result.fold((_) {}, (_) {});
  }

  Future<void> _defaultFirebaseInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  SyncHealthData _buildSyncHealthData() {
    final healthRepository = HealthRepositoryImpl(
      HealthPlatformDataSourceImpl(health: Health()),
    );
    final duelRepository = DuelRepositoryImpl(
      DuelFirestoreDataSource(FirebaseFirestore.instance),
    );
    return SyncHealthData(healthRepository, duelRepository);
  }
}
