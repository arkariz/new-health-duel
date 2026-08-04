import 'dart:convert';

import 'package:health_duel/core/offline_queue/domain/entities/queued_action.dart';

/// JSON (de)serialization for [QueuedAction], persisted as a single string
/// entry per Hive box key.
class QueuedActionModel {
  const QueuedActionModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.dedupKey,
    required this.createdAtMillis,
    required this.attemptCount,
    this.lastAttemptAtMillis,
  });

  factory QueuedActionModel.fromEntity(QueuedAction entity) => QueuedActionModel(
        id: entity.id,
        type: entity.type.name,
        payload: entity.payload,
        dedupKey: entity.dedupKey,
        createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
        attemptCount: entity.attemptCount,
        lastAttemptAtMillis: entity.lastAttemptAt?.millisecondsSinceEpoch,
      );

  factory QueuedActionModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return QueuedActionModel(
      id: map['id'] as String,
      type: map['type'] as String,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      dedupKey: map['dedupKey'] as String,
      createdAtMillis: map['createdAtMillis'] as int,
      attemptCount: map['attemptCount'] as int,
      lastAttemptAtMillis: map['lastAttemptAtMillis'] as int?,
    );
  }

  /// Raw enum name — kept as a string (not [OfflineActionType]) so an
  /// unrecognized future/removed type can be tolerated (skipped) rather than
  /// throwing during deserialization.
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final String dedupKey;
  final int createdAtMillis;
  final int attemptCount;
  final int? lastAttemptAtMillis;

  /// Returns `null` when [type] doesn't match a known [OfflineActionType] —
  /// callers should skip such entries rather than fail the whole read.
  QueuedAction? toEntity() {
    OfflineActionType? matchedType;
    for (final candidate in OfflineActionType.values) {
      if (candidate.name == type) {
        matchedType = candidate;
        break;
      }
    }
    if (matchedType == null) return null;

    return QueuedAction(
      id: id,
      type: matchedType,
      payload: payload,
      dedupKey: dedupKey,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      attemptCount: attemptCount,
      lastAttemptAt: lastAttemptAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastAttemptAtMillis!)
          : null,
    );
  }

  String toJson() => jsonEncode({
        'id': id,
        'type': type,
        'payload': payload,
        'dedupKey': dedupKey,
        'createdAtMillis': createdAtMillis,
        'attemptCount': attemptCount,
        'lastAttemptAtMillis': lastAttemptAtMillis,
      });
}
