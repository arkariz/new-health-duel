# Phase 4: Duel Feature Architecture Design

**Planner Agent:** af181d6
**Date:** 2026-02-14
**Status:** Approved for Implementation

---

## Executive Summary

This is an excellent use case for Clean Architecture + BLoC with real-time capabilities. The key challenge is managing **multiple real-time streams** (Firestore duel updates, health data sync, countdown timer) while maintaining clean separation of concerns.

---

## 1. Domain Layer Design

### 1.1 Core Entity: Duel (Aggregate Root)

**File:** `lib/features/duel/domain/entities/duel.dart`

Rich domain model with business logic for 24-hour step competitions.

**Business Methods:**
- `isActive` - Check if duel is currently active
- `isPending` - Check if awaiting acceptance
- `isCompleted` - Check if finished
- `isExpired` - Check if 24-hour window passed
- `isPendingExpired` - Check if invitation expired (24h)
- `remainingTime` - Get Duration remaining
- `pendingTimeRemaining` - Time left to accept
- `timeElapsedPercentage` - Progress (0.0 - 1.0)
- `currentLeader` - Get current winner (nullable if tie)
- `result` - Get DuelResult (winner/tie) at completion
- `isParticipant(userId)` - Check if user is in duel
- `getOpponentId(userId)` - Get opponent's ID
- `getStepsForUser(userId)` - Get step count for user
- `stepDifference` - Absolute step difference

**Properties:**
```dart
final DuelId id;
final UserId challengerId;
final UserId challengedId;
final StepCount challengerSteps;
final StepCount challengedSteps;
final DateTime startTime;
final DateTime endTime;
final DuelStatus status;
final DateTime createdAt;
final DateTime? acceptedAt;
final DateTime? completedAt;
```

---

## 2. Value Objects

### 2.1 DuelId
**File:** `lib/features/duel/domain/value_objects/duel_id.dart`

Simple wrapper around String ID.

### 2.2 UserId
**File:** `lib/features/duel/domain/value_objects/user_id.dart`

Wrapper around user ID string.

### 2.3 StepCount
**File:** `lib/features/duel/domain/value_objects/step_count.dart`

**Features:**
- Validation: Cannot be negative
- Implements `Comparable<StepCount>`
- Operators: `+`, `-`, `>`, `<`, `>=`, `<=`
- Factory: `StepCount.zero()`

### 2.4 DuelStatus (enum)
**File:** `lib/features/duel/domain/value_objects/duel_status.dart`

**Values:**
- `pending` - Challenge sent, awaiting acceptance
- `active` - Both accepted, competition in progress
- `completed` - 24-hour window ended
- `cancelled` - User cancelled before acceptance
- `expired` - Pending invitation expired

**Helper methods:**
- `canBeAccepted`
- `canBeCancelled`
- `isInProgress`
- `isFinal`

### 2.5 DuelResult (sealed class)
**File:** `lib/features/duel/domain/value_objects/duel_result.dart`

**Variants:**
- `WinnerResult` - Contains winnerId, loserId, steps, margin
- `TieResult` - Contains both participants, tied step count

**Factory methods:**
- `DuelResult.winner(...)`
- `DuelResult.tie(...)`

---

## 3. Use Cases

### 3.1 CreateDuel
**File:** `lib/features/duel/domain/usecases/create_duel.dart`

**Validation:**
- Cannot challenge yourself
- Cannot have active duel with same user

**Returns:** `Either<Failure, Duel>`

### 3.2 AcceptDuel
**File:** `lib/features/duel/domain/usecases/accept_duel.dart`

**Validation:**
- Only pending duels can be accepted
- Check if invitation expired

**Side effects:**
- Sets status to `active`
- Records `acceptedAt` timestamp
- Calculates `startTime` and `endTime` (24h window)

### 3.3 DeclineDuel
**File:** `lib/features/duel/domain/usecases/decline_duel.dart`

Sets duel status to `cancelled`.

### 3.4 UpdateStepCount
**File:** `lib/features/duel/domain/usecases/update_step_count.dart`

**Validation:**
- Only active duels can be updated
- User must be participant

### 3.5 GetActiveDuels
**File:** `lib/features/duel/domain/usecases/get_active_duels.dart`

Get list of active duels for user.

### 3.6 GetPendingDuels
**File:** `lib/features/duel/domain/usecases/get_pending_duels.dart`

Get list of pending invitations for user.

### 3.7 GetDuelHistory
**File:** `lib/features/duel/domain/usecases/get_duel_history.dart`

Get list of completed duels for user.

### 3.8 WatchDuel (Real-time)
**File:** `lib/features/duel/domain/usecases/watch_duel.dart`

**Returns:** `Stream<Either<Failure, Duel>>`

Firestore real-time listener for single duel.

### 3.9 SyncHealthData
**File:** `lib/features/duel/domain/usecases/sync_health_data.dart`

**Dependencies:**
- `HealthRepository` - Fetch steps from Health plugin
- `DuelRepository` - Update duel with fetched steps

**Flow:**
1. Get duel to extract time window
2. Fetch steps from Health platform (startTime → now)
3. Update duel with step count

---

## 4. Repository Interface

**File:** `lib/features/duel/domain/repositories/duel_repository.dart`

**Methods:**
- `createDuel(challengerId, challengedId)` → `Future<Either<Failure, Duel>>`
- `acceptDuel(duelId)` → `Future<Either<Failure, Duel>>`
- `cancelDuel(duelId)` → `Future<Either<Failure, void>>`
- `getDuelById(duelId)` → `Future<Either<Failure, Duel>>`
- `getActiveDuels(userId)` → `Future<Either<Failure, List<Duel>>>`
- `getPendingDuels(userId)` → `Future<Either<Failure, List<Duel>>>`
- `getDuelHistory(userId)` → `Future<Either<Failure, List<Duel>>>`
- `getActiveDuelBetween(userId1, userId2)` → `Future<Either<Failure, Duel?>>`
- `updateStepCount(duelId, userId, steps)` → `Future<Either<Failure, Duel>>`
- `watchDuel(duelId)` → `Stream<Either<Failure, Duel>>`
- `watchActiveDuels(userId)` → `Stream<Either<Failure, List<Duel>>>`

---

## 5. Firestore Schema

### Collection: `/duels/{duelId}`

**Fields:**
- `id` (string) - Document ID
- `challengerId` (string)
- `challengedId` (string)
- `challengerSteps` (number)
- `challengedSteps` (number)
- `status` (string) - 'pending' | 'active' | 'completed' | 'cancelled' | 'expired'
- `startTime` (timestamp)
- `endTime` (timestamp)
- `createdAt` (timestamp)
- `acceptedAt` (timestamp | null)
- `completedAt` (timestamp | null)
- `participants` (array<string>) - [challengerId, challengedId] for querying
- `winnerId` (string | null)

**Denormalized fields:**
- `challengerName` (string)
- `challengedName` (string)
- `challengerPhotoUrl` (string | null)
- `challengedPhotoUrl` (string | null)

### Firestore Indexes

**Index 1: Active duels for user**
```
Collection: duels
Fields:
  - participants (ARRAY_CONTAINS)
  - status (ASCENDING)
  - startTime (DESCENDING)
```

**Index 2: Pending duels**
```
Collection: duels
Fields:
  - challengedId (ASCENDING)
  - status (ASCENDING)
  - createdAt (DESCENDING)
```

**Index 3: Duel history**
```
Collection: duels
Fields:
  - participants (ARRAY_CONTAINS)
  - status (ASCENDING)
  - completedAt (DESCENDING)
```

---

## 6. Data Layer

### 6.1 DuelDto (Firestore DTO)
**File:** `lib/features/duel/data/models/duel_dto.dart`

**Methods:**
- `DuelDto.fromFirestore(DocumentSnapshot)` - Deserialize from Firestore
- `toFirestore()` - Serialize to Map
- `toEntity()` - Convert DTO → Domain Entity

**Mapping:**
- Timestamps → DateTime conversion
- String status → DuelStatus enum
- int steps → StepCount value object
- String IDs → DuelId, UserId value objects

### 6.2 DuelFirestoreDataSource
**File:** `lib/features/duel/data/datasources/duel_firestore_datasource.dart`

**Methods:**
- `createDuel(...)`
- `acceptDuel(duelId)`
- `cancelDuel(duelId)`
- `getDuelById(duelId)`
- `getActiveDuels(userId)`
- `getPendingDuels(userId)`
- `getDuelHistory(userId)`
- `updateStepCount(...)`
- `watchDuel(duelId)` - Real-time listener
- `watchActiveDuels(userId)` - Real-time listener

### 6.3 DuelRepositoryImpl
**File:** `lib/features/duel/data/repositories/duel_repository_impl.dart`

**Responsibilities:**
- Delegate to data source
- Map DTOs → Entities
- Handle exceptions → Failures
- Implement DuelRepository interface

---

## 7. Presentation Layer

### 7.1 DuelBloc (EffectBloc Pattern)
**File:** `lib/features/duel/presentation/bloc/duel_bloc.dart`

**Real-time Strategy:**

**3 Stream/Timer Subscriptions:**
1. **Firestore Listener** - `_duelStreamSubscription`
   - Listens to duel document changes
   - Emits `DuelRealTimeUpdateReceived` event

2. **Health Sync Timer** - `_healthSyncTimer`
   - Periodic: every 5 minutes
   - Triggers `DuelHealthSyncTriggered` event

3. **Countdown Timer** - `_countdownTimer`
   - Periodic: every 1 second
   - Triggers `DuelCountdownTick` event
   - Updates UI with remaining time

**States:**
- `DuelInitial`
- `DuelLoading`
- `DuelLoaded(duel, lastSyncTime, currentTime)`
- `DuelError(message)`

**Events:**
- `DuelLoadRequested(duelId)` - Start watching duel
- `DuelRealTimeUpdateReceived(result)` - Firestore update
- `DuelHealthSyncTriggered(duelId)` - Sync from Health
- `DuelCountdownTick()` - Timer tick (UI update)
- `DuelCompletionDetected(duelId)` - Duel expired

**Effects:**
- `LeadChangedEffect(newLeader)` - Show notification
- `DuelCompletedEffect(result)` - Navigate to result screen

**Important:**
- Cancel all subscriptions in `close()`
- Detect lead changes by comparing prev/current state
- Don't block UI during background health sync

### 7.2 Pages

**ActiveDuelScreen**
**File:** `lib/features/duel/presentation/pages/active_duel_screen.dart`

**Components:**
- Countdown timer (HH:MM:SS format)
- Step progress bars (both participants)
- Lead indicator (who's winning)
- Last sync timestamp
- Manual refresh button

**DuelListScreen**
**File:** `lib/features/duel/presentation/pages/duel_list_screen.dart`

**Sections:**
- Active duels (real-time updates)
- Pending invitations
- Duel history

**CreateDuelScreen**
**File:** `lib/features/duel/presentation/pages/create_duel_screen.dart`

**Flow:**
1. Select friend from list
2. Preview duel details
3. Confirm and send challenge

**DuelResultScreen**
**File:** `lib/features/duel/presentation/pages/duel_result_screen.dart`

**Display:**
- Winner/Loser/Tie
- Final step counts
- Margin of victory
- Share button

### 7.3 Widgets

**DuelCard**
- Display duel summary (opponent, status, steps)

**StepProgressBar**
- Visual progress comparison
- Current leader indicator

**CountdownTimer**
- Real-time countdown display
- Warning color when < 1 hour

**SyncIndicator**
- Last sync timestamp
- Loading state during sync

---

## 8. Integration

### 8.1 DI Module
**File:** `lib/features/duel/di/duel_module.dart`

**Register:**
- Data sources
- Repositories
- Use cases
- BLoCs (factories)

### 8.2 GoRouter Routes

**Add routes:**
- `/duel/list` - DuelListScreen
- `/duel/create` - CreateDuelScreen
- `/duel/active/:id` - ActiveDuelScreen
- `/duel/result/:id` - DuelResultScreen

**Navigation from Home:**
- "New Duel" button → `/duel/create`
- Active duel card → `/duel/active/:id`

---

## 9. Key Design Decisions

### ✅ DO:

1. **Use StreamSubscription for Firestore listeners** - Clean up in `close()`
2. **Separate Timer from State** - Timer triggers events, not state mutations
3. **Denormalize user data in Firestore** - Avoid n+1 queries for participant names/photos
4. **Use value objects** - StepCount, DuelId enforce invariants
5. **Implement rich domain entities** - Business logic in Duel entity
6. **Background health sync** - Don't block UI
7. **Detect state changes** - Lead changes detected by comparing prev/current state

### ❌ DON'T:

1. **Don't put Timer in State** - Timers are side effects
2. **Don't poll Firestore** - Use real-time listeners
3. **Don't sync health data on every tick** - Use 5-minute intervals
4. **Don't store HealthKit data in Firestore** - Sync on-demand
5. **Don't create entities in data layer** - Keep DTO→Entity mapping simple

---

## 10. Performance Optimizations

1. **Debounce health sync updates** - 3-second debounce
2. **Use const constructors** - Cache value objects
3. **Limit Firestore listener scope** - Single document, not collection
4. **Cache user data** - Denormalized in Firestore document

---

## 11. Implementation Order

### Phase 1: Domain Layer (Task 5)
1. Value objects (DuelId, UserId, StepCount, DuelStatus, DuelResult)
2. Duel entity
3. Repository interface
4. Use cases (all 9)

### Phase 2: Data Layer (Task 6)
1. DuelDto
2. DuelFirestoreDataSource
3. DuelRepositoryImpl
4. HealthDataSource integration

### Phase 3: Presentation Layer (Task 7)
1. DuelBloc (states, events, effects)
2. ActiveDuelScreen (most complex)
3. DuelListScreen
4. CreateDuelScreen
5. DuelResultScreen
6. Widgets

### Phase 4: Integration (Task 8)
1. DuelModule (DI)
2. GoRouter routes
3. Home navigation

### Phase 5: Testing & QA (Tasks 9-10)
1. Architecture review
2. Unit tests
3. Widget tests
4. Build verification

---

## 12. File Structure

```
lib/features/duel/
├── domain/
│   ├── entities/
│   │   └── duel.dart
│   ├── value_objects/
│   │   ├── duel_id.dart
│   │   ├── user_id.dart
│   │   ├── step_count.dart
│   │   ├── duel_status.dart
│   │   └── duel_result.dart
│   ├── repositories/
│   │   └── duel_repository.dart
│   └── usecases/
│       ├── create_duel.dart
│       ├── accept_duel.dart
│       ├── decline_duel.dart
│       ├── update_step_count.dart
│       ├── get_active_duels.dart
│       ├── get_pending_duels.dart
│       ├── get_duel_history.dart
│       ├── watch_duel.dart
│       └── sync_health_data.dart
├── data/
│   ├── models/
│   │   └── duel_dto.dart
│   ├── datasources/
│   │   └── duel_firestore_datasource.dart
│   └── repositories/
│       └── duel_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── duel_bloc.dart
│   │   ├── duel_event.dart
│   │   ├── duel_state.dart
│   │   └── duel_effect.dart
│   ├── pages/
│   │   ├── active_duel_screen.dart
│   │   ├── duel_list_screen.dart
│   │   ├── create_duel_screen.dart
│   │   └── duel_result_screen.dart
│   └── widgets/
│       ├── duel_card.dart
│       ├── step_progress_bar.dart
│       ├── countdown_timer.dart
│       └── sync_indicator.dart
└── di/
    └── duel_module.dart
```

**Total:** ~30 files

---

**End of Design Document**

**Next:** Implement domain layer (Task 5)
