# ADR-008: AuthCredentials as Write Model for Authentication

## 1. Metadata
- **Decision ID:** ADR-008
- **Date:** 2026-02-14
- **Roadmap Phase:** Phase 3.5 (Architecture Discussion)
- **Status:** Accepted
- **Scope:** Global - Session & Auth Features

## 2. Context (Why this decision exists)

Health Duel uses a separation between write operations (authentication validation) and read operations (displaying user data). After Phase 3 completion, the architecture review identified a naming confusion issue with the current implementation.

**Problem:**

The codebase has two "User" concepts:

1. **User entity** (`lib/data/session/domain/entities/user.dart`) - Domain layer entity for validating authentication inputs using value objects (Email, DisplayName, Password). This entity is used during register/login flows to enforce business rules before sending data to the backend.

2. **UserModel** (`lib/data/session/data/models/user_model.dart`) - Data layer DTO for Firestore serialization. Contains fields returned from Firebase (id, email, name, photoUrl, createdAt) used for displaying authenticated user data in the presentation layer.

The issue: **"User" vs "UserModel" creates conceptual confusion:**
- "User" sounds like the primary domain entity, but it's actually a transient validation facade that gets discarded after validation
- "UserModel" sounds like a DTO, but it's the actual user representation used throughout the application
- New developers must learn this implicit distinction: "which User do I use?"
- The pattern is architecturally sound but the naming obscures the design intent

**Analysis Conducted:**

Three expert perspectives were analyzed:

1. **DDD/CQRS Expert:** Pattern is valid (Command Model for writes, Query Model for reads), but naming is misleading. "User" entity is validation-only, not a true aggregate root.

2. **Clean Architecture Expert:** No violations, but architectural ambiguity exists. The pattern follows Clean Architecture principles but the naming creates layer confusion.

3. **Pragmatic Developer:** Not over-engineering—well-reasoned separation that aligns with real-world patterns (Reso Coder, production apps). Naming confusion is the main issue.

**Constraints:**
- Write operations need validation (Email, Password, DisplayName) before sending to backend
- Read operations need different fields (id, photoUrl, createdAt) that don't exist during registration
- Value objects enforce business invariants at compile-time (ADR-006)
- Presentation layer should not depend on write-side validation logic
- Must maintain Clean Architecture layer boundaries
- Must prepare for future domain entities (e.g., User aggregate for Duel business logic in Phase 4)

**Current Phase:**
Phase 3.5 focuses on resolving architectural ambiguities before building the Duel feature.

## 3. Decision

**We will rename the User entity to `AuthCredentials` to clarify its purpose as a write-side validation model for authentication flows.**

The entity will be renamed from:
```dart
class User {
  factory User.login({...});
  factory User.register({...});
}
```

To:
```dart
class AuthCredentials {
  factory AuthCredentials.forLogin({...});
  factory AuthCredentials.forRegister({...});
}
```

This change makes the architecture self-documenting: `AuthCredentials` clearly communicates "this validates authentication input," while `UserModel` remains as the actual user representation from the backend.

## 4. Options Considered

### Option A — Rename User → AuthCredentials (CHOSEN)
Rename the domain entity to explicitly indicate it's for authentication credential validation.

### Option B — Keep Current, Add Documentation
Maintain "User" as the entity name but add extensive documentation explaining it's validation-only.

### Option C — Full DDD Refactor
Introduce a true domain entity (User), separate command objects (RegisterRequest, LoginRequest), and explicit DTO ↔ Entity mappings.

### Option D — Merge into Single Model
Combine User entity and UserModel into one class with optional fields.

## 5. Trade-offs Analysis

### Option A — Rename User → AuthCredentials (CHOSEN)

**Pros:**
- (+) **Self-documenting code:** Name reveals intent without requiring documentation
- (+) **Reduced cognitive load:** No more "which User?" confusion
- (+) **Prepares for Phase 4:** Frees up "User" name for future domain entity with business logic (e.g., `user.canJoinDuel()`)
- (+) **Clear bounded context:** Auth context uses `AuthCredentials`, Session/Home contexts use `UserModel`
- (+) **Minimal refactor:** Just renaming, no architectural changes
- (+) **Team-friendly:** Junior developers immediately understand the distinction
- (+) **Aligns with CQRS:** Command model (AuthCredentials) vs Query model (UserModel)

**Cons:**
- (−) **Breaking change:** Requires updating imports across use cases and tests
- (−) **Git history:** File rename may affect blame/history tracking
- (−) **One-time effort:** ~6-8 files need updates

**Long-term Impact:**
- Improves codebase comprehension for new developers
- Establishes clear naming conventions for command/query models
- Enables future introduction of true User domain entity without name conflicts

---

### Option B — Keep Current, Add Documentation

**Pros:**
- (+) **Zero refactoring:** No code changes needed
- (+) **Preserves history:** Git blame remains intact

**Cons:**
- (−) **Documentation debt:** Developers won't always read docs
- (−) **Misleading naming:** "User" still implies primary entity
- (−) **Persistent confusion:** Doesn't solve the root cause
- (−) **Future conflicts:** Blocks using "User" for domain entity in Phase 4
- (−) **Implicit knowledge:** Requires tribal knowledge to understand distinction

**Long-term Impact:**
- Accumulates technical debt in comprehension
- May cause bugs when developers use wrong "User" type
- Onboarding friction remains

---

### Option C — Full DDD Refactor

**Pros:**
- (+) **Pure DDD:** Separate command objects, domain entities, and DTOs
- (+) **Maximum clarity:** Each concept has its own type
- (+) **Textbook architecture:** Follows DDD literature exactly

**Cons:**
- (−) **Over-engineering:** Excessive boilerplate for Flutter app
- (−) **Mapping overhead:** DTO ↔ Entity conversions add noise
- (−) **Violates ADR-006:** Entity creation would move back to data layer
- (−) **Premature abstraction:** No complex user behaviors yet
- (−) **High complexity:** More types to understand and maintain

**Long-term Impact:**
- Increases codebase complexity without proportional value
- May hinder development velocity
- Requires more sophisticated team understanding

---

### Option D — Merge into Single Model

**Pros:**
- (+) **Simplicity:** One "User" type
- (+) **Less code:** No duplicate fields

**Cons:**
- (−) **Loss of type safety:** Nullable fields allow invalid states
- (−) **Mixed concerns:** Validation and display logic in one class
- (−) **Violates SRP:** Single class serves two purposes
- (−) **Harder to test:** Validation scattered across codebase
- (−) **Primitive obsession:** Loses value object benefits

**Long-term Impact:**
- Reduces architecture quality
- Makes validation harder to enforce
- Increases bug risk

## 6. Consequences

### What Becomes Easier

1. **Code Comprehension:** Developers immediately understand `AuthCredentials.forRegister()` is for validation
2. **Onboarding:** New team members don't need to learn implicit "User vs UserModel" distinction
3. **Future Development:** "User" name available for true domain entity with business logic in Phase 4 (Duel feature)
4. **Architecture Reviews:** Code reviews become faster with self-documenting names
5. **Testing:** Test names become clearer (`AuthCredentials_forLogin_invalidEmail_throwsError`)

### What Becomes Harder

1. **Initial Refactor:** Must update ~6-8 files (use cases, tests, re-exports)
2. **Git History:** File rename may complicate `git blame` tracking (mitigated by IDE support)

### Accepted Risks

1. **One-time refactor cost:** ~30 minutes to rename and update all references
   - **Mitigation:** Use IDE refactoring tools for consistency
2. **Potential merge conflicts:** If parallel branches exist
   - **Mitigation:** Coordinate with team, perform refactor in dedicated branch
3. **Learning curve for existing contributors:** Those familiar with "User" entity
   - **Mitigation:** Document in ADR, announce in team chat, update CHANGELOG

## 7. Implementation Notes

### Files to Modify

**1. Rename entity file:**
```
From: lib/data/session/domain/entities/user.dart
To:   lib/data/session/domain/entities/auth_credentials.dart
```

**2. Update class and factory methods:**
```dart
// Before
class User extends Equatable {
  factory User.login({...}) { ... }
  factory User.register({...}) { ... }
}

// After
class AuthCredentials extends Equatable {
  factory AuthCredentials.forLogin({...}) { ... }
  factory AuthCredentials.forRegister({...}) { ... }
}
```

**3. Update re-export file:**
```dart
// lib/features/auth/domain/entities/user.dart
export 'package:health_duel/data/session/domain/entities/auth_credentials.dart';
```

**4. Update use cases:**
- `lib/features/auth/domain/usecases/register_with_email.dart`
- `lib/features/auth/domain/usecases/sign_in_with_email.dart`

**5. Update tests:**
- `test/features/auth/domain/usecases/register_with_email_test.dart`
- `test/features/auth/domain/usecases/sign_in_with_email_test.dart`

### Usage Examples

**Before (confusing):**
```dart
// Use case
class RegisterWithEmail {
  Future<Either<Failure, UserModel>> call(...) {
    final user = User.register(...);  // Which User?
    return repository.registerWithEmail(...);  // Returns UserModel
  }
}
```

**After (clear):**
```dart
// Use case
class RegisterWithEmail {
  Future<Either<Failure, UserModel>> call(...) {
    final credentials = AuthCredentials.forRegister(...);  // Validates input
    return repository.registerWithEmail(
      email: credentials.email.value,
      password: credentials.password.value,
      name: credentials.name.value,
    );  // Returns UserModel from backend
  }
}
```

### Anti-Patterns to Avoid

**❌ DON'T: Use AuthCredentials for non-auth flows**
```dart
// Wrong - AuthCredentials is auth-specific
class UpdateProfile {
  Future<Either<Failure, UserModel>> call() {
    final credentials = AuthCredentials.forRegister(...);  // Wrong context
  }
}
```

**❌ DON'T: Store AuthCredentials in BLoC state**
```dart
// Wrong - state should hold UserModel, not credentials
class AuthState {
  final AuthCredentials credentials;  // Contains password!
}
```

**✅ DO: Use AuthCredentials only for validation at use case boundary**
```dart
// Correct - validate, extract values, pass to repository
class SignInWithEmail {
  Future<Either<Failure, UserModel>> call(String email, String password) {
    try {
      final credentials = AuthCredentials.forLogin(
        email: email,
        password: password,
      );
      return repository.signInWithEmail(
        credentials.email.value,
        credentials.password.value,
      );
    } on ArgumentError catch (e) {
      return Left(ValidationFailure(e.message));
    }
  }
}
```

**✅ DO: Use UserModel for presentation/state management**
```dart
// Correct - state holds UserModel (read-side data)
class AuthState {
  final UserModel user;
  final bool isAuthenticated;
}
```

### Naming Conventions

**Command models (write-side validation):**
- `AuthCredentials` - Authentication input validation
- Future: `DuelInviteRequest`, `StepCountSubmission` (if needed in Phase 4)

**Query models (read-side data):**
- `UserModel` - User data from Firestore
- Future: `DuelModel`, `StepCountModel` (Phase 4)

**Domain entities (business logic):**
- Reserved for Phase 4: `User`, `Duel`, `StepCount` (if complex behavior emerges)

### Refactoring Checklist

- [ ] Rename file: `user.dart` → `auth_credentials.dart`
- [ ] Rename class: `User` → `AuthCredentials`
- [ ] Update factory methods: `.login()` → `.forLogin()`, `.register()` → `.forRegister()`
- [ ] Update imports in use cases
- [ ] Update imports in tests
- [ ] Update re-export file
- [ ] Run `flutter test` - expect 42/42 tests to pass
- [ ] Run `flutter analyze` - expect no new issues
- [ ] Run `flutter build apk --debug` - expect success
- [ ] Update this ADR status to "Implemented"
- [ ] Commit with message: "refactor: rename User entity to AuthCredentials (ADR-008)"

## 8. Revisit Criteria

This decision should be re-evaluated if:

1. **Phase 4 Duel Feature:** If true User domain entity is needed with business methods (e.g., `user.canStartDuel()`, `user.hasActiveChallenge()`), create it as a separate domain entity—AuthCredentials remains for auth validation

2. **Multiple Auth Flows:** If new authentication methods are added (OAuth, biometric, etc.), consider creating separate credential types: `EmailCredentials`, `OAuthCredentials`, `BiometricCredentials`

3. **Validation Complexity Grows:** If validation logic becomes complex enough to warrant dedicated validation services, refactor to Command pattern with validators

4. **Team Feedback:** If developers find "AuthCredentials" confusing or overly verbose, consider alternatives like `LoginForm`, `RegisterInput`, or `AuthInput`

5. **CQRS Evolution:** If full CQRS pattern is adopted with separate read/write repositories and event sourcing, revisit the naming to align with CQRS conventions

## 9. Related Artifacts

- **ADR-006:** Validation in Use Case Layer - Establishes that entity creation (validation) happens in use cases
- **Implementation Files:**
  - `lib/data/session/domain/entities/auth_credentials.dart` (renamed from user.dart)
  - `lib/data/session/domain/value_objects/email.dart`
  - `lib/data/session/domain/value_objects/password.dart`
  - `lib/data/session/domain/value_objects/display_name.dart`
  - `lib/data/session/data/models/user_model.dart` (read-side model)
- **Architecture Overview:** `docs/02-architecture/ARCHITECTURE_OVERVIEW.md`
- **Project Glossary:** `docs/00-foundation/PROJECT_GLOSSARY.md`

---

**Decision Author:** Health Duel Team (Lead Agent)
**Expert Analysis By:** DDD/CQRS Expert (abd6bb3), Clean Architecture Expert (a44641d), Pragmatic Developer (a636aaa)
**Approved Date:** 2026-02-14
**Implementation Status:** Approved, pending implementation
