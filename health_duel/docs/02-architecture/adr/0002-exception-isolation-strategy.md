# Exception Isolation at Repository Boundary

## 1. Metadata
- **Decision ID:** ADR-002
- **Date:** 2026-02-08
- **Roadmap Phase:** Phase 1 (Foundation & Core Architecture)
- **Status:** Accepted
- **Scope:** Global (affects all layers of Clean Architecture)

## 2. Context (Why this decision exists)

Health Duel follows **Clean Architecture** principles with strict layer separation:
Presentation → Domain → Data → Infrastructure.

**Problem:**
The `flutter-package-core` exception package provides rich `CoreException` types
(NoInternetConnectionException, ApiErrorException, FirestoreException, etc.)
that are thrown from data sources. We needed to decide whether:
1. Let these exceptions bubble up to the domain layer
2. Map them to domain-appropriate types at the repository boundary

**Constraints:**
- **Dependency Rule:** Inner layers (Domain) must NOT depend on outer layers
  (Infrastructure)
- **Testability:** Domain layer should be pure Dart without Flutter/infrastructure
  dependencies
- **Clean Architecture Compliance:** Non-negotiable requirement per foundational
  context
- **Learning Goal:** Proper implementation of architectural boundaries is core
  to Senior Engineer development path

## 3. Decision

**We will map `CoreException` to `Failure` types at the repository boundary.**

Domain layer will use an `Either<Failure, Success>` pattern where `Failure` is
a sealed class hierarchy defined in the domain layer. All `CoreException`
instances thrown from data sources will be caught and mapped by repositories
before returning to use cases.

## 4. Options Considered

**Option A — Let CoreException Bubble Up**
- Repositories re-throw CoreException
- Domain layer catches CoreException directly
- Use cases return Future<T> that throws

**Option B — Map to Failure at Repository (Chosen)**
- Repository catches CoreException
- Maps to domain Failure types
- Use cases return Either<Failure, T>

**Option C — Dual-Layer Exceptions**
- Keep CoreException for infrastructure
- Create domain exceptions extending CoreException
- Mix both patterns

## 5. Trade-offs Analysis (Critical Section)

### Option A — Let CoreException Bubble Up

**(+) Pros:**
- Less boilerplate code
- Rich exception metadata preserved
- Simpler initial implementation

**(−) Cons:**
- **Domain depends on infrastructure** (violates Dependency Rule)
- **Domain tests require exception package**
- Tight coupling between layers
- Harder to swap data sources
- Cannot test domain in isolation
- Firebase-specific exceptions leak into business logic

**Long-term Impact:**
Architectural erosion, violated Clean Architecture principles, domain layer
becomes untestable without Firebase/network dependencies.

---

### Option B — Map to Failure at Repository (Chosen)

**(+) Pros:**
- **Domain layer completely independent**
- **Domain tests don't need infrastructure packages**
- Easy to swap data source implementations
- Type-safe error handling with Either
- Explicit success/failure states
- Clear architectural boundaries
- Testable business logic without mocking Firebase

**(−) Cons:**
- More boilerplate (mapping code)
- Some exception metadata may be lost
- Additional layer of abstraction

**Long-term Impact:**
Maintainable, testable, true Clean Architecture. Easy to swap from Firestore to
another database without touching domain or presentation layers.

---

### Option C — Dual-Layer Exceptions

**(+) Pros:**
- Balance between options A and B
- Preserves some metadata

**(−) Cons:**
- Confusing exception hierarchy
- Still violates Dependency Rule
- Unclear boundaries
- Worst of both worlds

**Long-term Impact:**
Confused team, unclear error handling patterns, still couples domain to
infrastructure.

---

**Why Option B Wins:**
1. **Clean Architecture Compliance:** Strict adherence to Dependency Rule
2. **Testability:** Domain can be tested in pure Dart (no Flutter SDK needed)
3. **Flexibility:** Easy to change data sources without touching domain
4. **Type Safety:** Either<Failure, Success> makes error handling explicit
5. **Learning Goal:** Proper architectural boundaries align with Senior Engineer
   development path
6. **Future-Proof:** If we switch from Firebase to custom backend, domain layer
   unchanged

## 6. Consequences

### What Becomes Easier

- ✅ **Domain Testing:** Pure Dart unit tests without mocking infrastructure
- ✅ **Layer Independence:** Domain doesn't know about Dio, Hive, Firebase,
     HealthKit
- ✅ **Data Source Swapping:** Change from Firestore to custom API without
     touching domain
- ✅ **Error Reasoning:** Either<Failure, T> makes failure cases explicit
- ✅ **Business Logic Focus:** Domain layer focuses on duel rules, not Firebase
     errors
- ✅ **Team Onboarding:** New developers understand clear layer boundaries

### What Becomes Harder

- ❌ **Mapping Boilerplate:** Need to write exception mapping logic
- ❌ **Metadata Loss:** Rich CoreException data simplified to Failure.message
- ❌ **Debug Complexity:** May need to preserve errorCode for production debugging

### Accepted Risks

**Risk 1: Loss of Detailed Exception Metadata**
- CoreException provides detailed context (module, layer, function, errorCode)
- Mapping to Failure may lose some of this context

**Mitigation:**
```dart
// Preserve metadata in Failure
class NetworkFailure extends Failure {
  final String message;
  final String? errorCode;  // Preserve generated code
  final Map<String, dynamic>? metadata;  // Extra context

  NetworkFailure({
    required this.message,
    this.errorCode,
    this.metadata,
  });
}

// Rich mapping preserves important metadata
Failure _mapExceptionToFailure(CoreException e) {
  return NetworkFailure(
    message: e.message ?? 'Network error',
    errorCode: e.generatedCode(code: e.code),
    metadata: {
      'module': e.module,
      'layer': e.layer,
      'function': e.function,
    },
  );
}
```

**Risk 2: Additional Code to Maintain**
- Mapping logic must be updated when new exceptions added

**Mitigation:**
- Use centralized ExceptionMapper (see Implementation Notes)
- Single source of truth for all exception mapping
- Add new exception types in one place

**Risk 3: Potential for Inconsistent Mapping**
- Different repositories might map same exception differently

**Mitigation:**
- Centralized ExceptionMapper ensures consistency
- Code review checklist includes exception mapping verification
- Document standard Failure types in ADR

## 7. Implementation Notes

### Failure Hierarchy (Domain Layer)

```dart
// lib/core/error/failures.dart
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Authentication failures
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message);
}

// Network failures
final class NetworkFailure extends Failure {
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const NetworkFailure(
    super.message, {
    this.errorCode,
    this.metadata,
  });

  @override
  List<Object?> get props => [message, errorCode, metadata];
}

// Server/Firestore failures
final class ServerFailure extends Failure {
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const ServerFailure(
    super.message, {
    this.errorCode,
    this.metadata,
  });

  @override
  List<Object?> get props => [message, errorCode, metadata];
}

// Cache/storage failures
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Health data failures (Health Duel specific)
final class HealthDataFailure extends Failure {
  const HealthDataFailure(super.message);
}

final class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(super.message);
}

// Generic failure for unexpected errors
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
```

### Centralized Exception Mapping (Recommended)

To reduce boilerplate and ensure consistency, use a centralized `ExceptionMapper`:

```dart
// lib/core/error/exception_mapper.dart
import 'package:flutter_package_core/exception.dart';
import 'failures.dart';

class ExceptionMapper {
  static Failure toFailure(CoreException exception) {
    return switch (exception) {
      // Firebase Auth exceptions
      FireAuthUserNotFoundException() =>
        const AuthFailure('No account found with this email'),
      FireAuthWrongPasswordException() =>
        const AuthFailure('Invalid email or password'),
      FireAuthInvalidEmailException() =>
        const ValidationFailure('Invalid email format'),
      FireAuthEmailAlreadyInUseException() =>
        const AuthFailure('Email already registered'),
      FireAuthWeakPasswordException() =>
        const ValidationFailure('Password too weak (minimum 6 characters)'),
      FireAuthUserDisabledException() =>
        const AuthFailure('This account has been disabled'),
      FireAuthTooManyRequestsException() =>
        const AuthFailure('Too many login attempts. Please try again later'),
      FireAuthOperationNotAllowedException() =>
        const AuthFailure('This sign-in method is not enabled'),
      FireAuthInvalidCredentialException() =>
        const AuthFailure('Invalid credentials'),
      FireAuthAccountExistsWithDifferentCredentialException() =>
        const AuthFailure('Account exists with different sign-in method'),
      FireAuthInvalidVerificationCodeException() =>
        const ValidationFailure('Invalid verification code'),

      // Firestore exceptions
      FirestoreException(:final code, :final message) => ServerFailure(
        message ?? 'Database error',
        errorCode: code,
        metadata: {'source': 'firestore'},
      ),

      // Network exceptions
      NoInternetConnectionException() =>
        const NetworkFailure('No internet connection. Please check your network'),
      RequestTimeOutException() =>
        const NetworkFailure('Request timeout. Please try again'),
      ApiErrorException(:final message) =>
        ServerFailure(message ?? 'Server error'),

      // Storage exceptions
      LocalStorageCorruptionException() =>
        const CacheFailure('Local storage corrupted. Please clear app data'),
      LocalStorageException(:final message) =>
        CacheFailure(message ?? 'Storage error'),

      // Health data exceptions (platform-specific)
      HealthDataUnavailableException() =>
        const HealthDataFailure('Health data unavailable. Please enable health permissions'),
      HealthDataPermissionDeniedException() =>
        const PermissionDeniedFailure('Health data permission denied. Enable in device settings'),

      // Default fallback
      _ => UnexpectedFailure(
        exception.message ?? 'An unexpected error occurred',
      ),
    };
  }
}
```

### Repository Implementation Pattern

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:flutter_package_core/exception.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> signIn(
    String email,
    String password,
  ) async {
    try {
      final firebaseUser = await _remoteDataSource.signIn(email, password);
      final user = UserModel.fromFirebaseUser(firebaseUser).toEntity();
      return Right(user);
    } on CoreException catch (e) {
      // Use centralized mapper - NO duplicate mapping logic
      return Left(ExceptionMapper.toFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final firebaseUser = await _remoteDataSource.register(
        email,
        password,
        displayName,
      );
      final user = UserModel.fromFirebaseUser(firebaseUser).toEntity();
      return Right(user);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    }
  }
}
```

**Benefits of Centralized Mapping:**
- ✅ **DRY Principle:** Single source of truth for all exception mapping
- ✅ **Consistency:** All features map exceptions the same way
- ✅ **Maintainability:** Update once, applies everywhere
- ✅ **Scalability:** New exceptions added in one place
- ✅ **Reduced Boilerplate:** ~80 lines removed per repository

### When to Add Feature-Specific Mapping

Only if truly unique business logic is needed (e.g., special handling of
Firestore permission-denied for duels):

```dart
class DuelRepositoryImpl implements DuelRepository {
  @override
  Future<Either<Failure, Duel>> getDuel(String id) async {
    try {
      final duelDto = await _remoteDataSource.getDuel(id);
      return Right(duelDto.toEntity());
    } on FirestoreException catch (e) {
      // Custom business logic for specific Firestore error
      if (e.code == 'permission-denied') {
        return const Left(
          AuthorizationFailure('You are not a participant in this duel'),
        );
      }
      // Fallback to centralized mapper
      return Left(ExceptionMapper.toFailure(e));
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    }
  }
}
```

### Use Case Pattern

```dart
// lib/features/duel/domain/usecases/create_duel.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/duel.dart';
import '../repositories/duel_repository.dart';

class CreateDuel {
  final DuelRepository _repository;

  CreateDuel(this._repository);

  Future<Either<Failure, Duel>> call(DuelParams params) async {
    // Domain-level validation
    if (params.challengedId == params.challengerId) {
      return const Left(
        ValidationFailure('Cannot challenge yourself'),
      );
    }

    // Delegate to repository
    return await _repository.createDuel(params);
  }
}
```

### Presentation Layer Handling

```dart
// lib/features/duel/presentation/bloc/duel_bloc.dart
Future<void> _onCreateDuel(
  CreateDuel event,
  Emitter<DuelState> emit,
) async {
  emit(DuelLoading());

  final result = await _createDuel(event.params);

  result.fold(
    (failure) {
      emit(DuelError(_mapFailureToMessage(failure)));
      addEffect(ShowErrorSnackbar(_mapFailureToMessage(failure)));
    },
    (duel) {
      emit(DuelCreated(duel));
      addEffect(NavigateToDuelDetails(duel.id));
    },
  );
}

String _mapFailureToMessage(Failure failure) {
  return switch (failure) {
    NetworkFailure(:final message) => message,
    ServerFailure(:final message) => message,
    AuthFailure(:final message) => message,
    ValidationFailure(:final message) => message,
    AuthorizationFailure(:final message) => message,
    HealthDataFailure(:final message) => message,
    PermissionDeniedFailure(:final message) => message,
    CacheFailure(:final message) => message,
    UnexpectedFailure(:final message) => message,
  };
}
```

### Anti-patterns to Avoid

❌ **DO NOT:**
- Import exception package in domain layer
- Let CoreException leak to use cases
- Use try-catch in use cases (failures are in Either)
- Create circular dependencies (Failure → CoreException)
- Create local `_mapExceptionToFailure` methods in repositories (use
  centralized ExceptionMapper)

✅ **DO:**
- Use centralized ExceptionMapper.toFailure()
- Define all Failure types in core/error/failures.dart
- Return Either<Failure, T> from all repository methods
- Handle Either in presentation layer with fold()

### Boundaries to Maintain

```
✅ Data Layer    → Can import exception package
✅ Data Layer    → Maps CoreException to Failure via ExceptionMapper
❌ Domain Layer  → NEVER imports exception package
❌ Domain Layer  → Only knows Failure types
✅ Domain Layer  → Returns Either<Failure, T>
```

## 8. Revisit Criteria

This decision should be re-evaluated if:

### Quantitative Triggers

1. **Mapping Becomes Excessive:** ExceptionMapper exceeds 500 lines
2. **Metadata Loss Critical:** > 5 production incidents require full exception
   context that Failure doesn't preserve
3. **Performance Impact:** Exception mapping measurably impacts app performance
   (> 100ms overhead)

### Qualitative Triggers

4. **Framework Evolution:** Dart introduces language-level error handling
   improvements that obsolete Either pattern
5. **Team Feedback:** Multiple developers find mapping too complex or
   confusing
6. **Alternative Emerges:** Better pattern for exception isolation discovered
   in Flutter community
7. **Clean Architecture Deprecated:** Community consensus shifts away from
   strict layer boundaries

### Phase Gates

- **Phase 1 Retrospective:** Evaluate ExceptionMapper complexity and coverage
- **Phase 2 Launch:** Assess production error tracking needs
- **6-Month Review:** Determine if metadata loss caused debugging issues

### Will NOT Revisit

- "Too much boilerplate" without architectural justification
- Short-term convenience over long-term maintainability
- Pressure to violate Dependency Rule for faster development

## 9. Related Artifacts

### Documentation
- [Architecture Overview](../ARCHITECTURE_OVERVIEW.md) - Layer architecture
- [Architecture Vision](../../00-foundation/ARCHITECTURE_VISION.md) - Design
  principles
- [Contributing Guidelines](../../CONTRIBUTING.md) - Error handling standards

### Code References
- `lib/core/error/failures.dart` - Domain failure hierarchy
- `lib/core/error/exception_mapper.dart` - Centralized exception mapping
- `flutter-package-core/exception` - CoreException types (git dependency)

### Related ADRs
- [ADR-001: Selective Caching Strategy](0001-selective-caching-strategy.md)
- [ADR-007: Git Dependency Strategy](0007-git-dependency-strategy.md)

### External References
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Guide](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Dartz Package Documentation](https://pub.dev/packages/dartz)

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead, Coder-Docs
**Approved Date:** 2026-02-08
**Implementation Status:** Accepted for Phase 1, pattern established from reference
project
