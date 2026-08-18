import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User Model (Global Data Layer - Firestore DTO)
///
/// Handles serialization between Firestore documents and domain entities.
/// This model is used across features for user data.
class UserModel extends Equatable {

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt, this.photoUrl,
  });

  /// Create from Firestore document snapshot
  ///
  /// Document ID is used as user ID (same as Firebase Auth UID).
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from Firestore data map (for queries)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create empty model
  factory UserModel.empty() => UserModel(
    id: '',
    name: '',
    email: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  /// Convert to Firestore document data
  ///
  /// Note: ID is not included as it's the document ID, not a field.
  ///
  /// Email is deliberately NOT written here. `users/{uid}` is readable by
  /// any signed-in user (needed for friend/opponent name search), and
  /// Firestore security rules can only restrict which *documents* are
  /// readable, never which *fields* within them — so keeping email out of
  /// the document entirely is the only way to keep it private. The
  /// signed-in user's own email is already available from Firebase Auth;
  /// no other user's email is ever needed by this app.
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt];

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
