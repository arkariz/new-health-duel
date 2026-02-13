import 'package:exception/exception.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:health_duel/data/session/data/data.dart';

/// Auth Remote Data Source Interface
///
/// Defines the contract for Firebase Authentication operations.
/// Extends [SessionDataSource] for global session operations.
/// Returns [UserModel] (DTO) instead of raw UID for atomic auth + bootstrap.
abstract class AuthRemoteDataSource implements SessionDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password);

  /// Sign in with Google OAuth
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple OAuth (iOS only)
  Future<UserModel> signInWithApple();

  /// Register new user with email, password, and name
  Future<UserModel> registerWithEmail(String email, String password, String name);
}

/// Auth Remote Data Source Implementation
///
/// Extends [FirebaseSessionDataSource] for session operations and
/// implements auth-specific operations (sign in, register).
///
/// Uses atomic user bootstrap pattern:
/// - Every auth method ensures user document exists in Firestore
/// - Document ID = Firebase Auth UID (critical for security rules)
/// - Uses processFireauthCall and processFirestoreCall for exception handling
class AuthRemoteDataSourceImpl extends FirebaseSessionDataSource implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({super.firebaseAuth, super.firestore, super.googleSignIn});

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithEmail',
      call: () async {
        final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

        return bootstrapUser(credential.user!);
      },
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithGoogle',
      call: () async {
        // Trigger Google sign-in flow
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw firebase_auth.FirebaseAuthException(code: 'sign-in-canceled', message: 'Google sign in was canceled');
        }

        // Obtain auth details
        final googleAuth = await googleUser.authentication;
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        final authResult = await firebaseAuth.signInWithCredential(credential);

        return bootstrapUser(authResult.user!);
      },
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithApple',
      call: () async {
        final appleProvider =
            firebase_auth.AppleAuthProvider()
              ..addScope('email')
              ..addScope('name');

        final authResult = await firebaseAuth.signInWithProvider(appleProvider);

        return bootstrapUser(authResult.user!);
      },
    );
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password, String name) async {
    return processFireauthCall(
      module: 'Auth',
      function: 'registerWithEmail',
      call: () async {
        // Create Firebase Auth account
        final credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

        final user = credential.user!;

        // Update display name
        await user.updateDisplayName(name);

        // Bootstrap with provided name (not from Firebase yet)
        return bootstrapUserWithName(user, name);
      },
    );
  }
}
