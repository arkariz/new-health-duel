import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart';

/// Duel Data Transfer Object (Firestore DTO)
///
/// Handles serialization between Firestore documents and domain entities.
class DuelDto {
  final String id;
  final String challengerId;
  final String challengedId;
  final int challengerSteps;
  final int challengedSteps;
  final String status;
  final int startTimestamp;
  final int endTimestamp;
  final int createdAtTimestamp;
  final int? acceptedAtTimestamp;
  final int? completedAtTimestamp;
  final List<String> participants;
  final String? winnerId;

  // Denormalized user data for UI (avoid n+1 queries)
  final String challengerName;
  final String challengedName;
  final String? challengerPhotoUrl;
  final String? challengedPhotoUrl;

  const DuelDto({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.challengerSteps,
    required this.challengedSteps,
    required this.status,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.createdAtTimestamp,
    this.acceptedAtTimestamp,
    this.completedAtTimestamp,
    required this.participants,
    this.winnerId,
    required this.challengerName,
    required this.challengedName,
    this.challengerPhotoUrl,
    this.challengedPhotoUrl,
  });

  /// Create from Firestore document
  factory DuelDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DuelDto(
      id: doc.id,
      challengerId: data['challengerId'] as String,
      challengedId: data['challengedId'] as String,
      challengerSteps: data['challengerSteps'] as int? ?? 0,
      challengedSteps: data['challengedSteps'] as int? ?? 0,
      status: data['status'] as String,
      startTimestamp: (data['startTime'] as Timestamp).millisecondsSinceEpoch,
      endTimestamp: (data['endTime'] as Timestamp).millisecondsSinceEpoch,
      createdAtTimestamp:
          (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      acceptedAtTimestamp:
          (data['acceptedAt'] as Timestamp?)?.millisecondsSinceEpoch,
      completedAtTimestamp:
          (data['completedAt'] as Timestamp?)?.millisecondsSinceEpoch,
      participants: List<String>.from(data['participants'] as List),
      winnerId: data['winnerId'] as String?,
      challengerName: data['challengerName'] as String,
      challengedName: data['challengedName'] as String,
      challengerPhotoUrl: data['challengerPhotoUrl'] as String?,
      challengedPhotoUrl: data['challengedPhotoUrl'] as String?,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() => {
        'challengerId': challengerId,
        'challengedId': challengedId,
        'challengerSteps': challengerSteps,
        'challengedSteps': challengedSteps,
        'status': status,
        'startTime': Timestamp.fromMillisecondsSinceEpoch(startTimestamp),
        'endTime': Timestamp.fromMillisecondsSinceEpoch(endTimestamp),
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtTimestamp),
        'acceptedAt': acceptedAtTimestamp != null
            ? Timestamp.fromMillisecondsSinceEpoch(acceptedAtTimestamp!)
            : null,
        'completedAt': completedAtTimestamp != null
            ? Timestamp.fromMillisecondsSinceEpoch(completedAtTimestamp!)
            : null,
        'participants': participants,
        'winnerId': winnerId,
        'challengerName': challengerName,
        'challengedName': challengedName,
        'challengerPhotoUrl': challengerPhotoUrl,
        'challengedPhotoUrl': challengedPhotoUrl,
      };

  /// Convert DTO to Domain Entity
  Duel toEntity() {
    return Duel(
      id: id,
      challengerId: challengerId,
      challengedId: challengedId,
      challengerSteps: StepCount(challengerSteps),
      challengedSteps: StepCount(challengedSteps),
      status: DuelStatus.values.byName(status),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTimestamp),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTimestamp),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      acceptedAt: acceptedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(acceptedAtTimestamp!)
          : null,
      completedAt: completedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAtTimestamp!)
          : null,
    );
  }

  /// Create DTO from Domain Entity
  ///
  /// Note: Denormalized user data (names, photos) must be provided separately.
  factory DuelDto.fromEntity(
    Duel duel, {
    required String challengerName,
    required String challengedName,
    String? challengerPhotoUrl,
    String? challengedPhotoUrl,
  }) {
    return DuelDto(
      id: duel.id,
      challengerId: duel.challengerId,
      challengedId: duel.challengedId,
      challengerSteps: duel.challengerSteps.value,
      challengedSteps: duel.challengedSteps.value,
      status: duel.status.name,
      startTimestamp: duel.startTime.millisecondsSinceEpoch,
      endTimestamp: duel.endTime.millisecondsSinceEpoch,
      createdAtTimestamp: duel.createdAt.millisecondsSinceEpoch,
      acceptedAtTimestamp: duel.acceptedAt?.millisecondsSinceEpoch,
      completedAtTimestamp: duel.completedAt?.millisecondsSinceEpoch,
      participants: [duel.challengerId, duel.challengedId],
      winnerId: duel.isCompleted ? duel.currentLeader : null,
      challengerName: challengerName,
      challengedName: challengedName,
      challengerPhotoUrl: challengerPhotoUrl,
      challengedPhotoUrl: challengedPhotoUrl,
    );
  }
}
