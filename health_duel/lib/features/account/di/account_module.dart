import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/account/data/datasources/account_remote_data_source.dart';
import 'package:health_duel/features/account/data/repositories/account_repository_impl.dart';
import 'package:health_duel/features/account/domain/repositories/account_repository.dart';
import 'package:health_duel/features/account/domain/usecases/delete_account.dart';
import 'package:health_duel/features/account/domain/usecases/requires_password_reauth.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_bloc.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

/// Account Module Dependency Injection
///
/// Registers account deletion + Settings screen dependencies.
/// Must be called after auth, session, and health modules (reuses their
/// FirebaseAuth/FirebaseFirestore/GoogleSignIn singletons and the
/// SignOut / RevokeHealthPermissions use cases).
void registerAccountModule() {
  final getIt = GetIt.instance;

  getIt
    ..registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(
        firebaseAuth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    )
    ..registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(remoteDataSource: getIt<AccountRemoteDataSource>()),
    )
    ..registerFactory<RequiresPasswordReauth>(
      () => RequiresPasswordReauth(getIt<AccountRepository>()),
    )
    ..registerFactory<DeleteAccount>(
      () => DeleteAccount(getIt<AccountRepository>()),
    )
    ..registerFactory<SettingsBloc>(
      () => SettingsBloc(
        sessionRepository: getIt<SessionRepository>(),
        signOut: getIt<SignOut>(),
        requiresPasswordReauth: getIt<RequiresPasswordReauth>(),
        deleteAccount: getIt<DeleteAccount>(),
        revokeHealthPermissions: getIt<RevokeHealthPermissions>(),
      ),
    );
}
