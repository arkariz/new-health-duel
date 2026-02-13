import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_duel/data/session/data/data.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:health_duel/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';

/// Auth Module Dependency Injection
///
/// Registers all authentication-related dependencies:
/// - External Services: FirebaseAuth, FirebaseFirestore, GoogleSignIn
/// - Data Sources: AuthRemoteDataSource (also provides SessionDataSource)
/// - Repositories: AuthRepository
/// - Use Cases: SignIn, Register, SignOut, GetCurrentUser
/// - Presentation: AuthBloc
///
/// Also registers [SessionDataSource] for global session module.
///
/// Must be called after [registerCoreModule] completes.
void registerAuthModule() {
  final getIt = GetIt.instance;

  // ========================
  // External Services
  // ========================
  // Register as factories to allow testing with mocks

  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }

  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  }

  // ========================
  // Data Sources
  // ========================

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  // Register as SessionDataSource for global session module
  // AuthRemoteDataSource implements SessionDataSource
  getIt.registerLazySingleton<SessionDataSource>(
    () => getIt<AuthRemoteDataSource>(),
  );

  // ========================
  // Repositories
  // ========================

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()));

  // ========================
  // Use Cases
  // ========================

  getIt.registerFactory<SignInWithEmail>(() => SignInWithEmail(getIt<AuthRepository>()));

  getIt.registerFactory<SignInWithGoogle>(() => SignInWithGoogle(getIt<AuthRepository>()));

  getIt.registerFactory<SignInWithApple>(() => SignInWithApple(getIt<AuthRepository>()));

  getIt.registerFactory<RegisterWithEmail>(() => RegisterWithEmail(getIt<AuthRepository>()));

  // NOTE: GetCurrentUser and SignOut are registered by session_module
  // using global SessionRepository, not AuthRepository

  // ========================
  // Presentation (Bloc)
  // ========================

  // IMPORTANT: LazySingleton ensures single AuthBloc instance across app
  // - Router uses it for redirect logic
  // - BlocProvider.value provides same instance to widget tree
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      sessionRepository: getIt<SessionRepository>(),
      signInWithEmail: getIt<SignInWithEmail>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signInWithApple: getIt<SignInWithApple>(),
      registerWithEmail: getIt<RegisterWithEmail>(),
      signOut: getIt<SignOut>(),
    ),
  );
}
