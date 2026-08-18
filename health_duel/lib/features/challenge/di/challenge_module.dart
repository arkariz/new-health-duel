import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/challenge/data/data.dart';
import 'package:health_duel/features/challenge/domain/domain.dart';
import 'package:health_duel/features/challenge/presentation/bloc/challenge_bloc.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

/// Challenge Module Dependency Injection
///
/// Registers the solo-challenge feature (M3 "solo spine"). Must be
/// called after session and health modules are registered.
void registerChallengeModule() {
  final getIt = GetIt.instance;

  getIt
    ..registerLazySingleton<SoloChallengeFirestoreDataSource>(
      () => SoloChallengeFirestoreDataSource(getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<SoloChallengeRepository>(
      () => SoloChallengeRepositoryImpl(getIt<SoloChallengeFirestoreDataSource>()),
    )
    ..registerFactory(() => StartSoloChallenge(getIt<SoloChallengeRepository>()))
    ..registerFactory(() => GetActiveSoloChallenge(getIt<SoloChallengeRepository>()))
    ..registerFactory(() => CompleteSoloChallenge(getIt<SoloChallengeRepository>()))
    ..registerFactory(() => GetSoloChallengeHistory(getIt<SoloChallengeRepository>()))
    ..registerFactory(() => WatchSoloChallenge(getIt<SoloChallengeRepository>()))
    ..registerFactory(
      () => SyncSoloChallengeHealthData(
        getIt<HealthRepository>(),
        getIt<SoloChallengeRepository>(),
      ),
    )
    ..registerFactory(
      () => SoloChallengeBloc(
        getActiveSoloChallenge: getIt<GetActiveSoloChallenge>(),
        startSoloChallenge: getIt<StartSoloChallenge>(),
        watchSoloChallenge: getIt<WatchSoloChallenge>(),
        syncHealthData: getIt<SyncSoloChallengeHealthData>(),
        completeSoloChallenge: getIt<CompleteSoloChallenge>(),
        recordChallengeCompletion: getIt<RecordChallengeCompletion>(),
        sessionRepository: getIt<SessionRepository>(),
        checkHealthPermissions: getIt<CheckHealthPermissions>(),
        requestHealthPermissions: getIt<RequestHealthPermissions>(),
      ),
    );
}
