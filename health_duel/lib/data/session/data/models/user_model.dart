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
    required this.createdAt,
    this.photoUrl,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
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
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastCompletedDate: data['lastCompletedDate'] as String?,
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
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastCompletedDate: map['lastCompletedDate'] as String?,
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

  /// Consecutive days a solo challenge target was hit, ending at
  /// [lastCompletedDate]. Not eagerly zeroed by a missed day — see
  /// `StreakDisplay.effectiveCurrentStreak` for the lazy, display-time
  /// reset (there's no Cloud Functions cron to do it server-side).
  final int currentStreak;
  final int longestStreak;

  /// Local calendar date (`yyyy-MM-dd`) of the last successful challenge
  /// completion. A string, not a UTC timestamp, so streak day boundaries
  /// follow the user's own clock and survive timezone travel correctly.
  final String? lastCompletedDate;

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
  ///
  /// Only used for initial account creation (`set`, never `update`) — the
  /// streak fields are updated separately, scoped to just those three
  /// keys (see firestore.rules), so this always writing zero/null defaults
  /// here is safe.
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastCompletedDate': lastCompletedDate,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    createdAt,
    currentStreak,
    longestStreak,
    lastCompletedDate,
  ];

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
