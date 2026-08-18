import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exception/exception.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// Account Remote Data Source
///
/// Handles permanent account deletion against Firebase Auth + Firestore.
/// This is the only place that touches both — everything else in the app
/// treats them as separate concerns.
abstract class AccountRemoteDataSource {
  /// True if the signed-in account is email/password (needs a typed
  /// password to re-authenticate). False for Google accounts.
  bool requiresPasswordReauth();

  /// Delete the current user's account and all of their Firestore data.
  /// See `AccountRepository.deleteAccount` for the exact deletion order.
  Future<void> deleteAccount({String? password});
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {

  AccountRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _usersCollection = 'users';
  static const String _duelsCollection = 'duels';

  /// What a deleted user's name/photo become on any duel they leave
  /// behind — see the anonymize-own-fields rule in firestore.rules.
  static const String _anonymizedName = 'Deleted user';

  @override
  bool requiresPasswordReauth() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  @override
  Future<void> deleteAccount({String? password}) {
    return processFireauthCall(
      module: 'Account',
      function: 'deleteAccount',
      call: () async {
        final user = _firebaseAuth.currentUser;
        if (user == null) {
          throw firebase_auth.FirebaseAuthException(
            code: 'no-current-user',
            message: 'No signed-in user to delete',
          );
        }

        // Re-authenticate FIRST, before anything destructive: Firebase
        // requires a recent sign-in for `delete()`, and doing this last
        // would risk wiping Firestore data while leaving the Auth account
        // itself alive if the fresh-credential check then failed.
        await _reauthenticate(user, password);

        final uid = user.uid;
        await _wipeFirestoreData(uid);

        await user.delete();

        // Defensive: `delete()` already ends the Firebase session, but the
        // native Google session can otherwise linger and silently
        // auto-sign-in on next launch.
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      },
    );
  }

  Future<void> _reauthenticate(firebase_auth.User user, String? password) async {
    final isPasswordAccount = user.providerData.any((p) => p.providerId == 'password');

    if (isPasswordAccount) {
      if (password == null || password.isEmpty) {
        throw firebase_auth.FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Password is required to confirm account deletion',
        );
      }
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    // Google account — re-trigger the native picker for a fresh token
    // instead of asking for typed input.
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'sign-in-canceled',
        message: 'Google sign-in was cancelled',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Anonymizes the user's own fields on every duel they took part in,
  /// deletes their friends list, then deletes `users/{uid}` — all in one
  /// atomic batch, run while the Auth session is still valid.
  Future<void> _wipeFirestoreData(String uid) async {
    final batch = _firestore.batch();

    final duelsSnapshot = await _firestore
        .collection(_duelsCollection)
        .where('participants', arrayContains: uid)
        .get();

    for (final doc in duelsSnapshot.docs) {
      final data = doc.data();
      if (data['challengerId'] == uid) {
        batch.update(doc.reference, {
          'challengerName': _anonymizedName,
          'challengerPhotoUrl': null,
        });
      } else if (data['challengedId'] == uid) {
        batch.update(doc.reference, {
          'challengedName': _anonymizedName,
          'challengedPhotoUrl': null,
        });
      }
    }

    final friendsSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection('friends')
        .get();
    for (final doc in friendsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection(_usersCollection).doc(uid));

    await batch.commit();
  }
}
