import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exception/exception.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_duel/data/session/data/datasources/session_data_source.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

/// Firebase Session Data Source Implementation (Global)
///
/// Provides session management operations using Firebase Auth + Firestore.
/// This is the base implementation that can be extended by feature-specific
/// data sources (e.g., AuthRemoteDataSource).
///
/// Operations:
/// - [signOut] - Sign out from Firebase and Google
/// - [getCurrentUser] - Get current user with Firestore bootstrap
/// - [authStateChanges] - Stream of auth state changes
///
/// Uses processFireauthCall and processFirestoreCall for exception handling.
class FirebaseSessionDataSource implements SessionDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  /// Storage key for users collection (ADR-003 compliant)
  static const String usersCollection = 'users';

  FirebaseSessionDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) :  firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<void> signOut() async {
    return processFireauthCall(
      module: 'Session',
      function: 'signOut',
      call: () async {
        // Sign out from Google if signed in
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }

        // Sign out from Firebase
        await firebaseAuth.signOut();
      },
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;

    return processFirestoreCall(
      module: 'Session',
      function: 'getCurrentUser',
      call: () async {
        final doc = await firestore.collection(usersCollection).doc(firebaseUser.uid).get();

        if (!doc.exists) {
          // Edge case: Auth exists but Firestore doesn't
          // Bootstrap the user document
          return bootstrapUser(firebaseUser);
        }

        return UserModel.fromFirestore(doc);
      },
    );
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await firestore.collection(usersCollection).doc(firebaseUser.uid).get();

        if (!doc.exists) {
          return await bootstrapUser(firebaseUser);
        }

        return UserModel.fromFirestore(doc);
      } catch (e) {
        // If Firestore fails, still return basic user info
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
      }
    });
  }

  /// Bootstrap user in Firestore (idempotent)
  ///
  /// Creates user document if it doesn't exist, returns existing if it does.
  /// Document ID = Firebase Auth UID for security rules.
  ///
  /// Flow:
  /// 1. Check if document exists in Firestore
  /// 2. If not → Create new document with auth data
  /// 3. Return UserModel (new or existing)
  Future<UserModel> bootstrapUser(firebase_auth.User authUser) async {
    return processFirestoreCall(
      module: 'Session',
      function: 'bootstrapUser',
      call: () async {
        final userDoc = firestore.collection(usersCollection).doc(authUser.uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          // Create new user document
          final newUser = UserModel(
            id: authUser.uid,
            name: authUser.displayName ?? authUser.email?.split('@').first ?? 'User',
            email: authUser.email ?? '',
            photoUrl: authUser.photoURL,
            createdAt: DateTime.now(),
          );

          await userDoc.set(newUser.toFirestore());
          return newUser;
        }

        // User exists, return existing
        return UserModel.fromFirestore(snapshot);
      },
    );
  }

  /// Bootstrap user with explicit name (for registration)
  ///
  /// Used when we have the name from registration form
  /// (displayName might not be updated in Firebase yet)
  Future<UserModel> bootstrapUserWithName(firebase_auth.User authUser, String name) async {
    return processFirestoreCall(
      module: 'Session',
      function: 'bootstrapUserWithName',
      call: () async {
        final userDoc = firestore.collection(usersCollection).doc(authUser.uid);

        final newUser = UserModel(
          id: authUser.uid,
          name: name,
          email: authUser.email ?? '',
          photoUrl: authUser.photoURL,
          createdAt: DateTime.now(),
        );

        await userDoc.set(newUser.toFirestore());
        return newUser;
      },
    );
  }
}
