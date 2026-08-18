import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/value_objects/challenge_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_metric.dart';

/// Solo Challenge Data Transfer Object (Firestore DTO)
class SoloChallengeDto {
  const SoloChallengeDto({
    required this.id,
    required this.userId,
    required this.metric,
    required this.target,
    required this.currentValue,
    required this.status,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.createdAtTimestamp,
    this.completedAtTimestamp,
  });

  factory SoloChallengeDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SoloChallengeDto(
      id: doc.id,
      userId: data['userId'] as String,
      metric: data['metric'] as String,
      target: data['target'] as int,
      currentValue: data['currentValue'] as int? ?? 0,
      status: data['status'] as String,
      startTimestamp: (data['startTime'] as Timestamp).millisecondsSinceEpoch,
      endTimestamp: (data['endTime'] as Timestamp).millisecondsSinceEpoch,
      createdAtTimestamp:
          (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      completedAtTimestamp:
          (data['completedAt'] as Timestamp?)?.millisecondsSinceEpoch,
    );
  }

  final String id;
  final String userId;
  final String metric;
  final int target;
  final int currentValue;
  final String status;
  final int startTimestamp;
  final int endTimestamp;
  final int createdAtTimestamp;
  final int? completedAtTimestamp;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'metric': metric,
        'target': target,
        'currentValue': currentValue,
        'status': status,
        'startTime': Timestamp.fromMillisecondsSinceEpoch(startTimestamp),
        'endTime': Timestamp.fromMillisecondsSinceEpoch(endTimestamp),
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtTimestamp),
        'completedAt': completedAtTimestamp != null
            ? Timestamp.fromMillisecondsSinceEpoch(completedAtTimestamp!)
            : null,
      };

  SoloChallenge toEntity() {
    return SoloChallenge(
      id: id,
      userId: userId,
      metric: DuelMetric.values.byName(metric),
      target: target,
      currentValue: currentValue,
      status: ChallengeStatus.values.byName(status),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTimestamp),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTimestamp),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp),
      completedAt: completedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAtTimestamp!)
          : null,
    );
  }
}
