# Project Glossary

This glossary defines all domain and technical terms used throughout the Health
Duel project. Terms are organized by category for easy navigation.

## Table of Contents

- [Duel Domain Terms](#duel-domain-terms)
- [Health Domain Terms](#health-domain-terms)
- [Technical Terms](#technical-terms)
- [Architecture Terms](#architecture-terms)
- [State Management Terms](#state-management-terms)
- [Firebase Terms](#firebase-terms)
- [Testing Terms](#testing-terms)

## Duel Domain Terms

### Challenge
An invitation sent by one user to another to start a duel. The challenge
contains metadata about the duel type, duration, and participants. A challenge
becomes an active **Duel** once the invited participant accepts.

### Duel
A 24-hour competition between two users comparing a health metric (steps in MVP).
A duel has distinct lifecycle states: **Pending**, **Active**, and **Completed**.

### Duel Lifecycle
The complete journey of a duel from creation to completion:
1. **Pending**: Challenge sent, awaiting acceptance
2. **Active**: Both participants accepted, competition in progress
3. **Completed**: 24-hour window ended, winner determined

Related: See ADR-006 for duel state management decisions.

### Participant
A user involved in a duel. Each duel has exactly two participants in MVP
(one challenger and one challenged). Future versions may support group duels.

### Winner
The participant with the highest step count at the end of the 24-hour duel
window. In case of a tie, both participants are considered winners.

### Step Count
The primary health metric for MVP duels. Represents the total number of steps
a participant takes during the active duel window. Sourced from **HealthKit**
(iOS) or **Health Connect** (Android).

### 24-Hour Window
The fixed duration for all MVP duels. Starts when both participants accept the
challenge. Timer countdown is displayed prominently in active duel UI.

### Lead
The current winning position in an active duel. The participant with the highest
step count "has the lead". Lead changes trigger push notifications to both
participants.

### Share Card
A dynamically generated image showing duel results, designed for social sharing.
Contains participant names, final step counts, winner/loser indicators, and
emojis. Exported as PNG for sharing via social apps.

### Punishment
A lighthearted consequence for the losing participant, displayed on the share
card. MVP uses a default emoji punishment (🙇). Future versions may allow
custom punishments.

## Health Domain Terms

### HealthKit
Apple's native health data framework for iOS. Provides secure access to user
health data stored in the Health app. Requires explicit user permission for
each data type accessed.

Related: See platform-specific setup in [Quick Start Guide](../QUICK_START.md).

### Health Connect
Google's unified health data API for Android. Aggregates health data from
multiple apps and devices. Requires permission declarations in AndroidManifest.xml
and runtime permission requests.

### Health Permission
User-granted authorization to access specific health data types. Health Duel
requests READ permission for step data only in MVP. Permissions must be requested
at runtime and can be revoked by users at any time.

### Step Data
Numerical count of steps taken by a user, recorded by device motion sensors or
connected fitness devices. Accessed via `health` Flutter plugin, which abstracts
platform differences between HealthKit and Health Connect.

### Health Sync
The process of fetching latest step data from platform health APIs and syncing
to Firestore. Occurs periodically during active duels to update progress.
Strategy defined in health sync ADR (TBD).

Related: See ADR-TBD for health sync strategy decisions.

## Technical Terms

### DTO (Data Transfer Object)
A plain data class used to transfer data between layers or across network
boundaries. DTOs are defined in the data layer and converted to/from domain
**Entities** via mappers.

Example:
```dart
class DuelDto {
  final String id;
  final String challengerId;
  final int challengerSteps;
  // ...

  DuelDto.fromFirestore(Map<String, dynamic> data);
  Map<String, dynamic> toFirestore();
}
```

### Entity
A core domain object that represents a business concept. Entities are defined
in the domain layer and are framework-agnostic. They contain business logic
and validation rules.

Example:
```dart
class Duel extends Equatable {
  final String id;
  final String challengerId;
  final DuelStatus status;

  bool get isActive => status == DuelStatus.active;
  Duration get remainingTime => endTime.difference(DateTime.now());
}
```

### Failure
A domain-level representation of an error. Failures are sealed classes that
represent different error categories (network, server, cache, validation).
Used in **Either** return types to handle errors functionally.

Example:
```dart
sealed class Failure extends Equatable {}
final class NetworkFailure extends Failure {}
final class ServerFailure extends Failure {
  final String message;
}
```

Related: See ADR-002 for exception isolation strategy.

### Either
A functional programming type from the `dartz` package that represents a value
of one of two possible types (a disjoint union). Used for error handling,
where `Left` contains a **Failure** and `Right` contains a success value.

Example:
```dart
Future<Either<Failure, Duel>> getDuel(String id) async {
  try {
    final duel = await _dataSource.getDuel(id);
    return Right(duel);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

### Effect
A side effect that should occur in response to a state change, but is not part
of the state itself. Effects are consumed once and include actions like
navigation, showing snackbars, or displaying dialogs.

Related: See ADR-004 for EffectBloc pattern and effect handling.

### Use Case
A single unit of business logic in the domain layer. Each use case implements
one specific action (e.g., CreateDuel, GetDuelById, UpdateDuelProgress).
Use cases coordinate between repositories and encapsulate business rules.

Example:
```dart
class CreateDuel {
  final DuelRepository _repository;

  CreateDuel(this._repository);

  Future<Either<Failure, Duel>> call(DuelParams params) async {
    // Validate params
    if (params.challengedId == params.challengerId) {
      return Left(ValidationFailure('Cannot challenge yourself'));
    }

    // Delegate to repository
    return await _repository.createDuel(params);
  }
}
```

## Architecture Terms

### Clean Architecture
A software architecture pattern that separates concerns into concentric layers,
with dependencies pointing inward. Core principle: inner layers (domain) know
nothing about outer layers (data, presentation).

**Layers in Health Duel:**
- **Domain**: Entities, repository interfaces, use cases (innermost)
- **Data**: Repository implementations, data sources, models
- **Presentation**: UI, BLoC, widgets (outermost)

Related: See [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md).

### Domain Layer
The innermost layer of Clean Architecture containing business logic. Has zero
dependencies on frameworks or external libraries (except Dart SDK). Contains
**Entities**, **Use Cases**, and **Repository** interfaces.

### Data Layer
The layer responsible for data access and persistence. Implements domain layer
**Repository** interfaces. Contains data sources (remote/local), **DTOs**,
and mappers to convert DTOs to **Entities**.

### Presentation Layer
The outermost layer containing UI and user interaction logic. Depends on the
domain layer for use cases but never directly on the data layer. Contains
widgets, **BLoC** classes, and view models.

### Repository Pattern
A design pattern that abstracts data access logic behind an interface. The
domain layer defines repository interfaces, while the data layer provides
implementations. This allows swapping data sources without affecting business logic.

Related: See [Development Patterns](../03-development/patterns/).

### Dependency Injection
A design pattern where dependencies are provided to a class from the outside
rather than created internally. Health Duel uses **GetIt** for dependency
injection, configured in module files.

Example:
```dart
final getIt = GetIt.instance;

void setupDuelModule() {
  getIt.registerLazySingleton(() => CreateDuel(getIt()));
  getIt.registerLazySingleton<DuelRepository>(() => DuelRepositoryImpl(getIt()));
}
```

### Module
A collection of related dependency injection registrations. Each feature has
its own module (e.g., AuthModule, DuelModule) that registers its dependencies
with **GetIt**.

## State Management Terms

### BLoC (Business Logic Component)
A state management pattern that separates business logic from UI. In BLoC,
widgets dispatch **Events** to the BLoC, which processes them and emits new
**States**. Health Duel uses the `flutter_bloc` package.

### EffectBloc
An extension of the standard BLoC pattern that adds support for one-time
**Effects** (side effects like navigation or snackbars). Defined in ADR-004.

Related: See ADR-004 for full EffectBloc pattern specification.

### Event
An input to a BLoC representing a user action or system event. Events are
sealed classes to ensure exhaustive handling.

Example:
```dart
sealed class DuelEvent extends Equatable {}
final class LoadDuel extends DuelEvent {
  final String duelId;
}
final class AcceptDuel extends DuelEvent {
  final String duelId;
}
```

### State
The output of a BLoC representing the current UI state. States are sealed
classes defining all possible UI configurations.

Example:
```dart
sealed class DuelState extends Equatable {}
final class DuelInitial extends DuelState {}
final class DuelLoading extends DuelState {}
final class DuelLoaded extends DuelState {
  final Duel duel;
}
final class DuelError extends DuelState {
  final String message;
}
```

### Effect (UI Effect)
A one-time side effect emitted by an **EffectBloc**. Effects are consumed
exactly once and represent actions that should occur in response to events
but are not part of the persistent state.

Example:
```dart
sealed class DuelEffect extends UiEffect {}
final class NavigateToDuelDetails extends DuelEffect {
  final String duelId;
}
final class ShowDuelError extends DuelEffect {
  final String message;
}
```

### EffectListener
A widget that listens to **Effects** emitted by an **EffectBloc** and executes
appropriate actions (navigation, snackbars, dialogs).

Example:
```dart
EffectListener<DuelBloc, DuelEffect>(
  listener: (context, effect) {
    switch (effect) {
      case NavigateToDuelDetails(:final duelId):
        context.push('/duel/$duelId');
      case ShowDuelError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(/*...*/);
    }
  },
  child: /* UI */,
)
```

## Firebase Terms

### Firebase Auth
Firebase service for user authentication. Supports email/password, Google,
Apple, and other providers. Health Duel uses Firebase Auth for user identity
management.

### Firestore
Firebase's NoSQL cloud database. Stores data as documents in collections.
Supports real-time listeners for live data updates. Health Duel stores duel
data, user profiles, and friend relationships in Firestore.

### FCM (Firebase Cloud Messaging)
Firebase service for sending push notifications to mobile devices. Health Duel
uses FCM to notify users of lead changes, duel start/end, and challenge
invitations.

### Cloud Functions
Serverless functions that run in response to Firebase events (Firestore
changes, Auth events, HTTP requests). Health Duel uses Cloud Functions for
duel lifecycle automation (start/end timers, winner calculation).

### Collection
A container for Firestore documents. Similar to a table in SQL databases.
Examples: `users`, `duels`, `notifications`.

### Document
A single record in a Firestore collection. Documents contain fields (key-value
pairs) and can have subcollections. Example: a document in the `duels`
collection represents one duel.

### Real-time Listener
A Firestore subscription that receives updates whenever a document or
collection changes. Used in Health Duel to show live duel progress updates
without polling.

Example:
```dart
_firestore.collection('duels').doc(duelId).snapshots().listen((snapshot) {
  final duel = DuelDto.fromFirestore(snapshot.data()!);
  // Update UI with new duel data
});
```

## Testing Terms

### Unit Test
A test that verifies a single unit of code (function, method, class) in
isolation. Uses mocks to isolate dependencies. Health Duel requires unit tests
for all domain logic (use cases, entities) and data layer (repositories).

### Widget Test
A test that verifies UI components (widgets) in isolation. Renders widgets in
a test environment and simulates user interactions. Health Duel requires widget
tests for custom widgets and screens.

### Integration Test
An end-to-end test that verifies complete user flows across multiple screens
and services. Runs on real or simulated devices. Health Duel uses integration
tests for critical flows (authentication, duel creation).

### Mock
A test double that simulates the behavior of a real object. Used to isolate
the code under test from external dependencies. Health Duel uses `mockito` to
generate mocks for repositories and data sources.

Example:
```dart
class MockDuelRepository extends Mock implements DuelRepository {}

test('should create duel', () async {
  final mockRepo = MockDuelRepository();
  when(mockRepo.createDuel(any)).thenAnswer((_) async => Right(testDuel));

  final useCase = CreateDuel(mockRepo);
  final result = await useCase(testParams);

  expect(result, Right(testDuel));
});
```

### Test Coverage
The percentage of code exercised by tests. Health Duel targets:
- Domain and data layers: 80%+ coverage
- Presentation layer: 60%+ coverage

Run coverage: `flutter test --coverage`

## Acronyms

- **ADR**: Architecture Decision Record
- **API**: Application Programming Interface
- **BLoC**: Business Logic Component
- **CI/CD**: Continuous Integration / Continuous Deployment
- **DTO**: Data Transfer Object
- **FCM**: Firebase Cloud Messaging
- **MVP**: Minimum Viable Product
- **PRD**: Product Requirements Document
- **SDK**: Software Development Kit
- **UI**: User Interface
- **UX**: User Experience

## Related Documents

- [Foundational Context](FOUNDATIONAL_CONTEXT.md) - Project vision and goals
- [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md) - System architecture
- [Product Requirements](../01-product/prd-health-duels-1.0.md) - Feature specifications
- [Development Patterns](../03-development/patterns/) - Code patterns and examples

---

**Last Updated:** 2026-02-08
**Version:** 1.0
