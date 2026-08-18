/// Test fixtures for consistent test data
///
/// Provides reusable test objects for unit and widget tests.
library;

import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/duel/data/models/duel_dto.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_status.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// User Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Standard test user model (DTO)
final tUserModel = UserModel(
  id: 'test-user-123',
  name: 'Test User',
  email: 'test@email.com',
  photoUrl: 'https://example.com/photo.jpg',
  createdAt: DateTime(2025),
);

/// User without photo
final tUserNoPhoto = UserModel(
  id: 'test-user-456',
  name: 'No Photo User',
  email: 'nophoto@example.com',
  createdAt: DateTime(2025),
);

/// User with empty name (fallback to email)
final tUserNoName = UserModel(
  id: 'test-user-789',
  name: '',
  email: 'noname@example.com',
  createdAt: DateTime(2025),
);

// ═══════════════════════════════════════════════════════════════════════════
// Auth Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Valid test email
const tEmail = 'test@email.com';

/// Valid test password
const tPassword = 'TestPassword123!';

/// Invalid test email
const tInvalidEmail = 'not-an-email';

/// Weak test password
const tWeakPassword = '123';

/// Test user name
const tName = 'Test User';

// ═══════════════════════════════════════════════════════════════════════════
// Error Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Standard error message
const tErrorMessage = 'Something went wrong';

/// Network error message
const tNetworkErrorMessage = 'No internet connection';

/// Auth error message
const tAuthErrorMessage = 'Invalid email or password';

// ═══════════════════════════════════════════════════════════════════════════
// Duel Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Opponent user model
final tOpponentModel = UserModel(
  id: 'opponent-user-456',
  name: 'Opponent User',
  email: 'opponent@example.com',
  createdAt: DateTime(2025),
);

/// Second opponent for opponent list tests
final tOpponent2Model = UserModel(
  id: 'opponent-user-789',
  name: 'Second Opponent',
  email: 'second@example.com',
  createdAt: DateTime(2025),
);

/// Fixed timestamps for deterministic duel tests
final tDuelStartTime = DateTime(2025, 6, 1, 10);
final tDuelEndTime = DateTime(2025, 6, 2, 10);
final tDuelCreatedAt = DateTime(2025, 6, 1, 9);
final tDuelAcceptedAt = DateTime(2025, 6, 1, 10);
final tDuelCompletedAt = DateTime(2025, 6, 2, 10, 5);

/// Time-sensitive timestamps for active/pending duels (evaluated at test runtime)
///
/// Active duels need a future endTime so [Duel.isActive] returns true.
/// Pending duels need a recent createdAt so [Duel.isPending] returns true.
DateTime get tActiveStartTime => DateTime.now().subtract(const Duration(hours: 1));
DateTime get tActiveEndTime => DateTime.now().add(const Duration(hours: 23));
DateTime get tPendingCreatedAt => DateTime.now().subtract(const Duration(hours: 1));

/// While a duel is pending, endTime holds createdAt + 24h (mirrors
/// createDuel's write) — [Duel.isPendingExpired]/[Duel.pendingTimeRemaining]
/// read endTime directly, so fixtures must keep this invariant.
DateTime get tPendingEndTime =>
    tPendingCreatedAt.add(const Duration(hours: 24));

const tDuelId = 'duel-active-123';
const tPendingDuelId = 'duel-pending-456';
const tHistoryDuelId = 'duel-history-789';
const tDuelErrorMessage = 'Failed to load duel';

/// Active duel — challenger is tUserModel, challenged is tOpponentModel
///
/// Uses runtime timestamps so [Duel.isActive] returns true.
Duel get tActiveDuel => Duel(
      id: tDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(1500),
      challengedValue: duel.StepCount(1200),
      status: DuelStatus.active,
      startTime: tActiveStartTime,
      endTime: tActiveEndTime,
      createdAt: tDuelCreatedAt,
      acceptedAt: tDuelAcceptedAt,
    );

/// Pending duel — challenger is tOpponentModel, challenged is tUserModel
///
/// Uses runtime createdAt so [Duel.isPending] returns true.
Duel get tPendingDuel => Duel(
      id: tPendingDuelId,
      challengerId: tOpponentModel.id,
      challengedId: tUserModel.id,
      challengerName: tOpponentModel.name,
      challengedName: tUserModel.name,
      challengerValue: duel.StepCount(0),
      challengedValue: duel.StepCount(0),
      status: DuelStatus.pending,
      startTime: tDuelStartTime,
      endTime: tPendingEndTime,
      createdAt: tPendingCreatedAt,
    );

const tSentDuelId = 'duel-sent-999';

/// Outgoing pending duel — current user (tUserModel) is the challenger
///
/// Uses runtime createdAt so [Duel.isPending] returns true.
Duel get tSentDuel => Duel(
      id: tSentDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(0),
      challengedValue: duel.StepCount(0),
      status: DuelStatus.pending,
      startTime: tDuelStartTime,
      endTime: tPendingEndTime,
      createdAt: tPendingCreatedAt,
    );

/// createdAt more than 24 hours ago, so [Duel.isPendingExpired] returns true.
DateTime get tExpiredPendingCreatedAt =>
    DateTime.now().subtract(const Duration(hours: 25));

/// endTime = createdAt + 24h, already in the past — mirrors the invariant
/// [Duel.isPendingExpired] relies on.
DateTime get tExpiredPendingEndTime =>
    tExpiredPendingCreatedAt.add(const Duration(hours: 24));

/// Expired pending invitation (received) — never accepted within 24 hours
Duel get tExpiredPendingDuel => Duel(
      id: tPendingDuelId,
      challengerId: tOpponentModel.id,
      challengedId: tUserModel.id,
      challengerName: tOpponentModel.name,
      challengedName: tUserModel.name,
      challengerValue: duel.StepCount(0),
      challengedValue: duel.StepCount(0),
      status: DuelStatus.pending,
      startTime: tDuelStartTime,
      endTime: tExpiredPendingEndTime,
      createdAt: tExpiredPendingCreatedAt,
    );

/// Expired outgoing pending challenge (sent) — never accepted within 24 hours
Duel get tExpiredSentDuel => Duel(
      id: tSentDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(0),
      challengedValue: duel.StepCount(0),
      status: DuelStatus.pending,
      startTime: tDuelStartTime,
      endTime: tExpiredPendingEndTime,
      createdAt: tExpiredPendingCreatedAt,
    );

/// Expired-but-still-active duel — endTime in the past, status still active
///
/// Uses runtime timestamps so [Duel.needsCompletion] returns true.
/// Challenger (tUserModel, 1500 steps) leads challenged (1200 steps).
DateTime get tExpiredStartTime => DateTime.now().subtract(const Duration(hours: 25));
DateTime get tExpiredEndTime => DateTime.now().subtract(const Duration(hours: 1));

Duel get tExpiredActiveDuel => Duel(
      id: tDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(1500),
      challengedValue: duel.StepCount(1200),
      status: DuelStatus.active,
      startTime: tExpiredStartTime,
      endTime: tExpiredEndTime,
      createdAt: tDuelCreatedAt,
      acceptedAt: tDuelAcceptedAt,
    );

/// [tExpiredActiveDuel] after client-side completion — status completed,
/// completedAt equals endTime (deterministic completion timestamp).
Duel get tJustCompletedDuel => Duel(
      id: tDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(1500),
      challengedValue: duel.StepCount(1200),
      status: DuelStatus.completed,
      startTime: tExpiredStartTime,
      endTime: tExpiredEndTime,
      createdAt: tDuelCreatedAt,
      acceptedAt: tDuelAcceptedAt,
      completedAt: tExpiredEndTime,
    );

/// Expired-active duel with equal step counts (tie scenario)
Duel get tExpiredTiedDuel => Duel(
      id: tDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
      challengerValue: duel.StepCount(1500),
      challengedValue: duel.StepCount(1500),
      status: DuelStatus.active,
      startTime: tExpiredStartTime,
      endTime: tExpiredEndTime,
      createdAt: tDuelCreatedAt,
      acceptedAt: tDuelAcceptedAt,
    );

/// Completed duel — challenger won
final tCompletedDuel = Duel(
  id: tHistoryDuelId,
  challengerId: tUserModel.id,
  challengedId: tOpponentModel.id,
  challengerName: tUserModel.name,
  challengedName: tOpponentModel.name,
  challengerValue: duel.StepCount(8000),
  challengedValue: duel.StepCount(6500),
  status: DuelStatus.completed,
  startTime: tDuelStartTime,
  endTime: tDuelEndTime,
  createdAt: tDuelCreatedAt,
  acceptedAt: tDuelAcceptedAt,
  completedAt: tDuelCompletedAt,
);

/// DuelDto matching [tActiveDuel] — used in repository/datasource tests
DuelDto tActiveDuelDto() => DuelDto(
      id: tDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerValue: 1500,
      challengedValue: 1200,
      status: DuelStatus.active.name,
      startTimestamp: tActiveStartTime.millisecondsSinceEpoch,
      endTimestamp: tActiveEndTime.millisecondsSinceEpoch,
      createdAtTimestamp: tDuelCreatedAt.millisecondsSinceEpoch,
      acceptedAtTimestamp: tDuelAcceptedAt.millisecondsSinceEpoch,
      participants: [tUserModel.id, tOpponentModel.id],
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
    );

/// DuelDto matching [tPendingDuel]
DuelDto tPendingDuelDto() => DuelDto(
      id: tPendingDuelId,
      challengerId: tOpponentModel.id,
      challengedId: tUserModel.id,
      challengerValue: 0,
      challengedValue: 0,
      status: DuelStatus.pending.name,
      startTimestamp: tDuelStartTime.millisecondsSinceEpoch,
      endTimestamp: tDuelEndTime.millisecondsSinceEpoch,
      createdAtTimestamp: tDuelCreatedAt.millisecondsSinceEpoch,
      participants: [tOpponentModel.id, tUserModel.id],
      challengerName: tOpponentModel.name,
      challengedName: tUserModel.name,
    );

/// DuelDto matching [tSentDuel]
DuelDto tSentDuelDto() => DuelDto(
      id: tSentDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerValue: 0,
      challengedValue: 0,
      status: DuelStatus.pending.name,
      startTimestamp: tDuelStartTime.millisecondsSinceEpoch,
      endTimestamp: tDuelEndTime.millisecondsSinceEpoch,
      createdAtTimestamp: tDuelCreatedAt.millisecondsSinceEpoch,
      participants: [tUserModel.id, tOpponentModel.id],
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
    );

/// DuelDto matching [tExpiredPendingDuel] after client-side expiration —
/// status expired
DuelDto tExpiredPendingDuelDto() => DuelDto(
      id: tPendingDuelId,
      challengerId: tOpponentModel.id,
      challengedId: tUserModel.id,
      challengerValue: 0,
      challengedValue: 0,
      status: DuelStatus.expired.name,
      startTimestamp: tDuelStartTime.millisecondsSinceEpoch,
      endTimestamp: tDuelEndTime.millisecondsSinceEpoch,
      createdAtTimestamp: tExpiredPendingCreatedAt.millisecondsSinceEpoch,
      participants: [tOpponentModel.id, tUserModel.id],
      challengerName: tOpponentModel.name,
      challengedName: tUserModel.name,
    );

/// DuelDto matching [tCompletedDuel]
DuelDto tCompletedDuelDto() => DuelDto(
      id: tHistoryDuelId,
      challengerId: tUserModel.id,
      challengedId: tOpponentModel.id,
      challengerValue: 8000,
      challengedValue: 6500,
      status: DuelStatus.completed.name,
      startTimestamp: tDuelStartTime.millisecondsSinceEpoch,
      endTimestamp: tDuelEndTime.millisecondsSinceEpoch,
      createdAtTimestamp: tDuelCreatedAt.millisecondsSinceEpoch,
      acceptedAtTimestamp: tDuelAcceptedAt.millisecondsSinceEpoch,
      completedAtTimestamp: tDuelCompletedAt.millisecondsSinceEpoch,
      participants: [tUserModel.id, tOpponentModel.id],
      challengerName: tUserModel.name,
      challengedName: tOpponentModel.name,
    );

// ═══════════════════════════════════════════════════════════════════════════
// Health Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Step count for health sync tests (value = 2500 steps)
const tSyncedSteps = 2500;

/// Creates a [StepDataRaw] record used in health sync tests
StepDataRaw tStepDataRaw() => (
      value: tSyncedSteps,
      startTime: tActiveStartTime,
      endTime: DateTime.now(),
      sourceDevice: 'test-device',
      hasManualEntries: false,
    );
