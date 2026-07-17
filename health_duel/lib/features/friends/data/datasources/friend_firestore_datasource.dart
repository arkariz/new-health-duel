import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

class FriendFirestoreDataSource {
  const FriendFirestoreDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _friendsOf(String userId) =>
      _firestore.collection('users').doc(userId).collection('friends');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<List<UserModel>> getFriends(String userId) async {
    final snap = await _friendsOf(userId).orderBy('name').get();
    return snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> addFriend(String currentUserId, UserModel friend) async {
    await _friendsOf(currentUserId).doc(friend.id).set({
      'id': friend.id,
      'name': friend.name,
      'email': friend.email,
      'photoUrl': friend.photoUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFriend(String currentUserId, String friendId) async {
    await _friendsOf(currentUserId).doc(friendId).delete();
  }

  Future<List<UserModel>> searchUsers(String query, String excludeUserId) async {
    if (query.trim().isEmpty) return [];
    final snap = await _usersCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '$query\uf8ff')
        .limit(20)
        .get();
    return snap.docs
        .where((doc) => doc.id != excludeUserId)
        .map(UserModel.fromFirestore)
        .toList();
  }
}
