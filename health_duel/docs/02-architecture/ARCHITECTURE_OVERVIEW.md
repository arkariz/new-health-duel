# Architecture Overview

This document provides a comprehensive overview of the Health Duel system
architecture, including layer organization, data flow, design patterns, and
technology stack.

## Table of Contents

- [Architectural Principles](#architectural-principles)
- [System Architecture](#system-architecture)
- [Layer Architecture](#layer-architecture)
- [Module Organization](#module-organization)
- [Data Flow](#data-flow)
- [Design Patterns](#design-patterns)
- [Technology Stack](#technology-stack)
- [Key Architectural Decisions](#key-architectural-decisions)

## Architectural Principles

Health Duel follows Clean Architecture principles with strict separation of
concerns across three layers:

### Core Principles

1. **Dependency Rule**: Dependencies point inward. Domain layer has zero
   dependencies on outer layers.
2. **Layer Independence**: Each layer can be tested and modified independently.
3. **Framework Agnostic Domain**: Business logic is pure Dart with no Flutter
   or external package dependencies.
4. **Interface-Based Design**: Outer layers implement interfaces defined in
   inner layers.
5. **Functional Error Handling**: Errors treated as data using Either type,
   not exceptions.

### Quality Attributes

- **Maintainability**: Code is organized, documented, and follows consistent patterns
- **Testability**: Each layer is independently testable with high coverage targets
- **Scalability**: Architecture supports adding features without modifying existing code
- **Performance**: Optimized for 60fps UI, fast startup, minimal battery drain

Related: See [Architecture Vision](../00-foundation/ARCHITECTURE_VISION.md) for
detailed principles.

## System Architecture

### High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Mobile Client (Flutter)                 │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Presentation Layer                       │  │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐    │  │
│  │  │ Widgets│  │  BLoC  │  │ Effects│  │ Router │    │  │
│  │  └────────┘  └────────┘  └────────┘  └────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │               Domain Layer                            │  │
│  │  ┌────────┐  ┌────────┐  ┌──────────────┐           │  │
│  │  │Entities│  │Use Cases│ │Repository    │           │  │
│  │  │        │  │        │  │Interfaces    │           │  │
│  │  └────────┘  └────────┘  └──────────────┘           │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                Data Layer                             │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │  │
│  │  │ Repository  │  │    Data     │  │   Models    │  │  │
│  │  │     Impl    │  │   Sources   │  │    (DTOs)   │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           │
                           ▼
      ┌────────────────────────────────────────┐
      │       External Services                 │
      │  ┌──────────┐  ┌──────────┐           │
      │  │ Firebase  │  │HealthKit │           │
      │  │  (Auth,   │  │  Health  │           │
      │  │Firestore, │  │ Connect  │           │
      │  │   FCM)    │  │          │           │
      │  └──────────┘  └──────────┘           │
      └────────────────────────────────────────┘
```

### System Components

**Mobile Client (Flutter)**
- Single codebase for iOS and Android
- Implements Clean Architecture with three distinct layers
- Communicates with external services via data layer

**External Services**
- **Firebase**: Backend-as-a-Service for auth, database, messaging
- **HealthKit** (iOS): Platform health data API
- **Health Connect** (Android): Platform health data API

## Layer Architecture

### Domain Layer (Innermost)

The core business logic layer with zero external dependencies.

**Location**: `lib/domain/`

**Responsibilities:**
- Define business entities (Duel, User, etc.)
- Define repository interfaces
- Implement use cases (business logic)
- Define failure types

**Dependencies**: None (pure Dart + utility packages like dartz, equatable)

**Structure:**
```
lib/domain/
└── [feature]/
    ├── entities/
    │   └── entity_name.dart          # Business objects
    ├── repositories/
    │   └── repository_interface.dart # Abstract repository
    └── usecases/
        └── use_case_name.dart        # Business logic
```

**Example:**
```dart
// lib/domain/duel/entities/duel.dart
class Duel extends Equatable {
  final String id;
  final String challengerId;
  final String challengedId;
  final int challengerSteps;
  final int challengedSteps;
  final DateTime startTime;
  final DateTime endTime;
  final DuelStatus status;

  const Duel({/* ... */});

  bool get isActive => status == DuelStatus.active;
  String get winnerId => challengerSteps > challengedSteps
      ? challengerId
      : challengedId;
  Duration get remainingTime => endTime.difference(DateTime.now());

  @override
  List<Object?> get props => [id, challengerId, challengedId, /* ... */];
}

// lib/domain/duel/repositories/duel_repository.dart
abstract class DuelRepository {
  Future<Either<Failure, Duel>> createDuel(DuelParams params);
  Future<Either<Failure, Duel>> getDuelById(String id);
  Future<Either<Failure, List<Duel>>> getActiveDuels(String userId);
  Stream<Duel> watchDuel(String id);
}

// lib/domain/duel/usecases/create_duel.dart
class CreateDuel {
  final DuelRepository _repository;

  CreateDuel(this._repository);

  Future<Either<Failure, Duel>> call(DuelParams params) async {
    // Validation logic
    if (params.challengedId == params.challengerId) {
      return Left(ValidationFailure('Cannot challenge yourself'));
    }

    // Delegate to repository
    return await _repository.createDuel(params);
  }
}
```

### Data Layer (Middle)

The data access and persistence layer implementing domain interfaces.

**Location**: `lib/data/`

**Responsibilities:**
- Implement repository interfaces from domain
- Fetch data from remote and local sources
- Convert between DTOs (models) and domain entities
- Handle data caching and offline storage
- Map exceptions to domain failures

**Dependencies**: Domain layer, Firebase packages, health package, storage packages

**Structure:**
```
lib/data/
└── [feature]/
    ├── models/
    │   └── model_name_dto.dart       # Data transfer objects
    ├── datasources/
    │   ├── remote_data_source.dart   # Firebase, network
    │   └── local_data_source.dart    # Hive, shared prefs
    ├── repositories/
    │   └── repository_impl.dart      # Repository implementation
    └── di/
        └── feature_module.dart       # Dependency injection setup
```

**Example:**
```dart
// lib/data/duel/models/duel_dto.dart
class DuelDto {
  final String id;
  final String challengerId;
  final String challengedId;
  final int challengerSteps;
  final int challengedSteps;
  final int startTimestamp;
  final int endTimestamp;
  final String status;

  const DuelDto({/* ... */});

  factory DuelDto.fromFirestore(Map<String, dynamic> data) {
    return DuelDto(
      id: data['id'] as String,
      challengerId: data['challenger_id'] as String,
      // ... parse all fields
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'challenger_id': challengerId,
      // ... all fields
    };
  }

  Duel toEntity() {
    return Duel(
      id: id,
      challengerId: challengerId,
      challengedId: challengedId,
      challengerSteps: challengerSteps,
      challengedSteps: challengedSteps,
      startTime: DateTime.fromMillisecondsSinceEpoch(startTimestamp),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTimestamp),
      status: DuelStatus.values.byName(status),
    );
  }
}

// lib/data/duel/repositories/duel_repository_impl.dart
class DuelRepositoryImpl implements DuelRepository {
  final DuelRemoteDataSource _remoteDataSource;
  final DuelLocalDataSource _localDataSource;

  DuelRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, Duel>> createDuel(DuelParams params) async {
    try {
      final duelDto = await _remoteDataSource.createDuel(params);
      final duel = duelDto.toEntity();
      await _localDataSource.cacheDuel(duelDto);
      return Right(duel);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    }
  }

  @override
  Stream<Duel> watchDuel(String id) {
    return _remoteDataSource
        .watchDuel(id)
        .map((dto) => dto.toEntity());
  }
}
```

### Presentation Layer (Outermost)

The user interface and interaction layer.

**Location**: `lib/features/`

**Responsibilities:**
- Display UI using Flutter widgets
- Handle user input and interactions
- Manage UI state with BLoC pattern
- Execute side effects (navigation, snackbars, dialogs)
- Dispatch events to BLoC based on user actions

**Dependencies**: Domain layer (use cases), Flutter packages, UI packages

**Structure:**
```
lib/features/
└── [feature]/
    ├── presentation/
    │   ├── bloc/
    │   │   ├── feature_bloc.dart     # BLoC implementation
    │   │   ├── feature_event.dart    # User actions
    │   │   ├── feature_state.dart    # UI states
    │   │   └── feature_effect.dart   # Side effects
    │   ├── screens/
    │   │   └── screen_name.dart      # Full screens
    │   └── widgets/
    │       └── widget_name.dart      # Reusable components
    └── di/
        └── feature_module.dart       # DI setup
```

**Example:**
```dart
// lib/features/duel/presentation/bloc/duel_event.dart
sealed class DuelEvent extends Equatable {}

final class LoadDuel extends DuelEvent {
  final String duelId;
  LoadDuel(this.duelId);
  @override
  List<Object> get props => [duelId];
}

final class AcceptDuel extends DuelEvent {
  final String duelId;
  AcceptDuel(this.duelId);
  @override
  List<Object> get props => [duelId];
}

// lib/features/duel/presentation/bloc/duel_state.dart
sealed class DuelState extends Equatable {}

final class DuelInitial extends DuelState {
  @override
  List<Object> get props => [];
}

final class DuelLoading extends DuelState {
  @override
  List<Object> get props => [];
}

final class DuelLoaded extends DuelState {
  final Duel duel;
  DuelLoaded(this.duel);
  @override
  List<Object> get props => [duel];
}

final class DuelError extends DuelState {
  final String message;
  DuelError(this.message);
  @override
  List<Object> get props => [message];
}

// lib/features/duel/presentation/bloc/duel_effect.dart
sealed class DuelEffect extends UiEffect {}

final class NavigateToDuelDetails extends DuelEffect {
  final String duelId;
  NavigateToDuelDetails(this.duelId);
}

final class ShowDuelError extends DuelEffect {
  final String message;
  ShowDuelError(this.message);
}

// lib/features/duel/presentation/bloc/duel_bloc.dart
class DuelBloc extends EffectBloc<DuelEvent, DuelState, DuelEffect> {
  final GetDuelById _getDuelById;
  final AcceptDuel _acceptDuel;

  DuelBloc({
    required GetDuelById getDuelById,
    required AcceptDuel acceptDuel,
  })  : _getDuelById = getDuelById,
        _acceptDuel = acceptDuel,
        super(DuelInitial()) {
    on<LoadDuel>(_onLoadDuel);
    on<AcceptDuel>(_onAcceptDuel);
  }

  Future<void> _onLoadDuel(LoadDuel event, Emitter<DuelState> emit) async {
    emit(DuelLoading());

    final result = await _getDuelById(event.duelId);

    result.fold(
      (failure) => emit(DuelError(failure.message)),
      (duel) => emit(DuelLoaded(duel)),
    );
  }

  Future<void> _onAcceptDuel(AcceptDuel event, Emitter<DuelState> emit) async {
    final result = await _acceptDuel(event.duelId);

    result.fold(
      (failure) => addEffect(ShowDuelError(failure.message)),
      (duel) => addEffect(NavigateToDuelDetails(duel.id)),
    );
  }
}
```

## Module Organization

### Core Module

Cross-cutting concerns shared across all features.

**Location**: `lib/core/`

**Components:**
```
lib/core/
├── config/
│   ├── app_config.dart       # Environment configuration
│   └── storage_keys.dart     # Storage key constants
├── di/
│   ├── core_module.dart      # Core DI setup
│   └── injection.dart        # GetIt instance
├── error/
│   ├── failures.dart         # Sealed failure types
│   └── exception_mapper.dart # Exception → Failure mapping
├── router/
│   └── app_router.dart       # GoRouter configuration
├── theme/
│   ├── app_theme.dart        # Theme data
│   ├── tokens/               # Design tokens
│   └── extensions/           # Theme extensions
├── bloc/
│   ├── effect_bloc.dart      # EffectBloc base class
│   └── ui_effect.dart        # UiEffect base class
├── presentation/
│   ├── widgets/              # Shared widgets
│   └── utils/                # UI utilities
└── utils/
    └── extensions/           # Dart extensions
```

### Feature Modules

Each feature is self-contained with its own domain, data, and presentation layers.

**Feature Structure:**
```
lib/features/[feature_name]/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── presentation/
│   ├── bloc/
│   ├── screens/
│   └── widgets/
└── di/
    └── [feature]_module.dart
```

**MVP Features:**
- `auth/` - Authentication and user management
- `duel/` - Duel creation, lifecycle, and results
- `health/` - Health data integration
- `friend/` - Friend management
- `notification/` - Push notification handling
- `profile/` - User profile management

## Data Flow

### Typical User Action Flow

```
User Interaction
       │
       ▼
   Widget dispatches Event
       │
       ▼
   BLoC receives Event
       │
       ▼
   BLoC calls Use Case (Domain)
       │
       ▼
   Use Case calls Repository Interface (Domain)
       │
       ▼
   Repository Implementation (Data) fetches from Data Source
       │
       ▼
   Data Source queries Firebase/Health APIs
       │
       ▼
   DTO returned to Repository
       │
       ▼
   Repository maps DTO → Entity
       │
       ▼
   Either<Failure, Entity> returned to Use Case
       │
       ▼
   Use Case returns Either to BLoC
       │
       ▼
   BLoC emits new State or Effect
       │
       ▼
   Widget rebuilds with new State / Effect triggers action
```

### Authentication Flow

```
                    ┌──────────────┐
                    │ Login Screen │
                    └──────┬───────┘
                           │ User enters credentials
                           ▼
                    ┌──────────────┐
                    │  Auth BLoC   │
                    └──────┬───────┘
                           │ LoginWithEmail event
                           ▼
                    ┌──────────────┐
                    │ SignIn UseCase│
                    └──────┬───────┘
                           │
                           ▼
          ┌────────────────────────────────┐
          │   Auth Repository (Interface)   │
          └────────────────┬───────────────┘
                           │
                           ▼
          ┌────────────────────────────────┐
          │ Auth Repository Implementation  │
          └────────────────┬───────────────┘
                           │
                           ▼
          ┌────────────────────────────────┐
          │    Auth Remote Data Source      │
          │    (Firebase Auth)              │
          └────────────────┬───────────────┘
                           │
                           ▼
                  Success / Failure
                           │
                           ▼
          ┌────────────────────────────────┐
          │   Session Data Source (Local)   │
          │   Store user token & profile    │
          └────────────────┬───────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Auth BLoC   │
                    │ Emit Authenticated State │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Navigate Home │
                    │  (Effect)     │
                    └───────────────┘
```

### Duel Creation Flow

```
User taps "New Duel" → Select Friend → Confirm
                           │
                           ▼
              ┌─────────────────────────┐
              │      Duel BLoC          │
              │  CreateDuel Event       │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │   CreateDuel Use Case   │
              │   (Validate params)     │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │   Duel Repository Impl  │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │ Duel Remote Data Source │
              │   (Create in Firestore) │
              └──────────┬──────────────┘
                         │
                         ▼
            Firestore Document Created
            Status: Pending
                         │
                         ▼
              ┌─────────────────────────┐
              │   Cloud Function         │
              │   onDuelCreated          │
              │   Send FCM to challenged │
              └──────────┬──────────────┘
                         │
                         ▼
              Challenged user receives
              push notification
                         │
                         ▼
              User accepts → Duel status: Active
```

### Health Data Sync Flow

```
              ┌─────────────────────────┐
              │  Active Duel Screen     │
              │  (Timer: every 5 min)   │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │     Health BLoC         │
              │  SyncStepData Event     │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │ GetStepData Use Case    │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │ Health Repository Impl  │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │ Health Data Source      │
              │ Query HealthKit/Health  │
              │ Connect for step count  │
              │ (filtered by time range)│
              └──────────┬──────────────┘
                         │
                         ▼
              Step count returned
                         │
                         ▼
              ┌─────────────────────────┐
              │ Update Duel in Firestore│
              │ with latest step count  │
              └──────────┬──────────────┘
                         │
                         ▼
              ┌─────────────────────────┐
              │   Cloud Function         │
              │   onDuelUpdated          │
              │   Check lead change      │
              └──────────┬──────────────┘
                         │
                         ▼
              Lead changed?
                  │        │
            Yes   │        │ No
                  ▼        ▼
          Send FCM    No action
          notification
```

## Design Patterns

### Repository Pattern

Abstract data access behind interfaces defined in domain layer.

**Benefits:**
- Decouples business logic from data sources
- Easy to swap implementations (e.g., mock for testing)
- Supports offline-first architecture

**Implementation:**
```dart
// Domain: Define interface
abstract class DuelRepository {
  Future<Either<Failure, Duel>> getDuelById(String id);
}

// Data: Implement interface
class DuelRepositoryImpl implements DuelRepository {
  final DuelRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Duel>> getDuelById(String id) async {
    // Implementation
  }
}
```

### BLoC Pattern (Business Logic Component)

Separate business logic from UI using event-driven state management.

**Benefits:**
- Clear separation of concerns
- Testable business logic
- Predictable state changes
- Time-travel debugging

**Implementation:**
- Widget dispatches Events
- BLoC processes Events and emits States
- Widget rebuilds on State changes

Related: See ADR-004 for EffectBloc pattern.

### EffectBloc Pattern

Extension of BLoC pattern adding support for one-time side effects.

**Problem**: Standard BLoC pattern conflates persistent state with transient
actions (navigation, snackbars).

**Solution**: Separate Effects from States. Effects are consumed once, States
persist.

**Implementation:**
```dart
abstract class EffectBloc<Event, State, Effect> extends Bloc<Event, State> {
  final _effectController = StreamController<Effect>.broadcast();
  Stream<Effect> get effectStream => _effectController.stream;

  void addEffect(Effect effect) {
    _effectController.add(effect);
  }
}
```

Related: See ADR-004 for complete pattern specification.

### Dependency Injection (Service Locator)

Use GetIt for dependency injection across all layers.

**Benefits:**
- Explicit dependencies
- Easy testing with mock injection
- Lazy initialization
- Single source of truth for instances

**Implementation:**
```dart
// Setup
final getIt = GetIt.instance;

void setupDuelModule() {
  // Data sources
  getIt.registerLazySingleton(() => DuelRemoteDataSource(getIt()));
  getIt.registerLazySingleton(() => DuelLocalDataSource(getIt()));

  // Repositories
  getIt.registerLazySingleton<DuelRepository>(
    () => DuelRepositoryImpl(getIt(), getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => CreateDuel(getIt()));
  getIt.registerLazySingleton(() => GetDuelById(getIt()));
}

// Usage in BLoC
class DuelBloc extends EffectBloc<...> {
  final CreateDuel _createDuel = getIt();
  final GetDuelById _getDuelById = getIt();
}
```

### Mapper Pattern

Convert between layer-specific representations (DTO ↔ Entity).

**Benefits:**
- Layers remain independent
- Data transformation centralized
- Type safety across boundaries

**Implementation:**
```dart
class DuelDto {
  Duel toEntity() {
    return Duel(/* map fields */);
  }

  factory DuelDto.fromEntity(Duel entity) {
    return DuelDto(/* map fields */);
  }
}
```

### Either Type (Functional Error Handling)

Use `Either<Failure, Success>` for all fallible operations.

**Benefits:**
- Forces explicit error handling
- Errors are data, not exceptions
- Type-safe error propagation
- Composable with functional operations

**Implementation:**
```dart
Future<Either<Failure, Duel>> createDuel(DuelParams params) async {
  try {
    final duel = await _dataSource.createDuel(params);
    return Right(duel);
  } on CoreException catch (e) {
    return Left(ExceptionMapper.toFailure(e));
  }
}

// Usage
final result = await createDuel(params);
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (duel) => print('Success: ${duel.id}'),
);
```

Related: See ADR-002 for exception isolation strategy.

## Technology Stack

### Frontend

**Flutter 3.7.2+**
- Cross-platform mobile framework
- Native performance with compiled Dart
- Hot reload for fast development
- Rich widget ecosystem

**State Management: flutter_bloc**
- Event-driven architecture
- Predictable state changes
- DevTools integration

**Navigation: go_router**
- Declarative routing
- Deep link support
- Type-safe navigation

**Dependency Injection: get_it**
- Service locator pattern
- Lazy initialization
- Simple API

**Functional Programming: dartz**
- Either type for error handling
- Option type for nullable values
- Functional combinators

### Backend

**Firebase**
- **Auth**: User authentication (email, Google, Apple)
- **Firestore**: NoSQL cloud database for duels, users, friends
- **Cloud Functions**: Serverless duel lifecycle automation
- **Cloud Messaging (FCM)**: Push notifications

### Health Integration

**health Package**
- Flutter plugin for health data
- iOS: HealthKit wrapper
- Android: Health Connect wrapper
- Unified API across platforms

### Storage

**Hive** (via flutter-package-core)
- Fast NoSQL local database
- Encrypted storage for sensitive data
- Type-safe boxes

**SharedPreferences**
- Simple key-value storage
- User preferences and settings

### Utilities

**equatable**: Value equality for entities and states
**intl**: Internationalization and date formatting
**uuid**: Unique identifier generation

## Key Architectural Decisions

All architectural decisions are documented as ADRs. Key decisions:

### ADR-001: Selective Caching Strategy
- Cache frequently accessed, rarely changed data
- Avoid caching real-time or user-specific data
- Reduces network calls and improves offline support

### ADR-002: Exception Isolation Strategy
- Exceptions caught at data layer boundary
- Mapped to domain Failures before crossing to domain
- Domain and presentation layers never handle raw exceptions

### ADR-003: Hybrid Storage Key Strategy
- Enum keys for global/core storage
- String keys for feature-specific storage
- Prevents key collisions and improves maintainability

### ADR-004: Registry-Based UI Effect Flow Architecture
- EffectBloc pattern separates state from side effects
- Effects consumed once, states persist
- Clear mental model for navigation, dialogs, snackbars

### ADR-005: Design Token Strategy
- Centralized design system with tokens
- AppSpacing, AppRadius, AppDurations, AppColors
- Consistent UI across features

### ADR-006: Thin Use Cases for Health Phase
- Use cases are thin orchestrators, not business logic containers
- Complex logic in entities or domain services
- Use cases focus on calling repositories and composing results

For complete ADR details, see [ADR directory](adr/).

## Related Documents

- [Architecture Vision](../00-foundation/ARCHITECTURE_VISION.md) - Architectural principles
- [Product Requirements](../01-product/prd-health-duels-1.0.md) - Feature specifications
- [Development Patterns](../03-development/patterns/) - Implementation patterns
- [ADR Index](adr/) - Architectural decision records

---

**Document Version:** 1.0
**Last Updated:** 2026-02-08
**Status:** Active - Guiding Development
