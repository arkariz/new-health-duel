# Fixer Agent Briefing - Phase 3 Critical Issues

**Agent Type:** Fixer (general-purpose)
**Task:** Fix 4 critical architecture issues found in review
**Duration Estimate:** 5-10 minutes
**Priority:** CRITICAL - Blocks QA

---

## 🎯 Your Mission

Fix 4 critical issues blocking QA:
1. Fix AuthBloc inheritance (EffectBloc pattern)
2. Fix HealthBloc inheritance (EffectBloc pattern)
3. Fix HomeBloc inheritance (EffectBloc pattern)
4. Fix User entity Clean Architecture violation

**Working Directory:** `C:\Work Stuff Personal\Project\new-health-duel\health_duel\`

---

## 📚 Required Reading

1. **`.claude/AGENT_CONTEXT.md`** (master context)
2. **`health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md`** (EffectBloc pattern)

---

## 🔧 Issue #1: AuthBloc - EffectBloc Pattern

**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Current (Line 31):**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState>
```

**Fix To:**
```dart
class AuthBloc extends EffectBloc<AuthEvent, AuthState>
```

**Import Required:**
- Already has: `import 'package:health_duel/core/bloc/bloc.dart';`
- EffectBloc is exported from this barrel file

**Method Changes Needed:**
- Replace `emit(state)` with `emitWithEffect(emit, state, effect)` for effects
- Keep regular `emit(state)` for non-effect state changes

**Verification:**
- AuthState already has UiEffect and EffectClearable ✅
- State props already excludes effect ✅
- Just need to change base class

---

## 🔧 Issue #2: HealthBloc - EffectBloc Pattern

**File:** `lib/features/health/presentation/bloc/health_bloc.dart`

**Current (Line 25):**
```dart
class HealthBloc extends Bloc<HealthEvent, HealthState>
```

**Fix To:**
```dart
class HealthBloc extends EffectBloc<HealthEvent, HealthState>
```

**Same Changes as AuthBloc:**
- Import already correct
- Change emit() to emitWithEffect() where effects are used
- HealthState already compliant ✅

---

## 🔧 Issue #3: HomeBloc - EffectBloc Pattern

**File:** `lib/features/home/presentation/bloc/home_bloc.dart`

**Current (Line 19):**
```dart
class HomeBloc extends Bloc<HomeEvent, HomeState>
```

**Fix To:**
```dart
class HomeBloc extends EffectBloc<HomeEvent, HomeState>
```

**Same Changes as AuthBloc:**
- Import already correct
- Change emit() to emitWithEffect() where effects are used
- HomeState already compliant ✅

---

## 🔧 Issue #4: User Entity - Clean Architecture Violation

**File:** `lib/data/session/domain/entities/user.dart`

**Current Problem:**
- Line 2: `import 'package:health_duel/core/error/error.dart';`
- Lines 29-30, 44-45: Throws `ValidationFailure`

**Why It's Wrong:**
- Domain layer (entities) should NOT depend on core layer (errors)
- Violates Clean Architecture Dependency Rule
- Domain should be the innermost layer with NO dependencies

**Fix Strategy:**

**Option A (Recommended - Simple):**
Remove validation from entity, move to use case layer:
```dart
// Remove import:
// import 'package:health_duel/core/error/error.dart';

// Change factory methods to NOT throw:
factory User.login({required String email, required String displayName}) {
  // Remove validation, just create entity
  return User(
    id: '',
    email: email,
    displayName: displayName,
    photoUrl: null,
    createdAt: DateTime.now(),
  );
}

factory User.register({
  required String email,
  required String displayName,
  String? photoUrl,
}) {
  // Remove validation, just create entity
  return User(
    id: '',
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    createdAt: DateTime.now(),
  );
}
```

**Validation should happen in:**
- Use cases layer (SignInWithEmail, RegisterWithEmail)
- Those can import core/error and return Either<Failure, User>

**Option B (Alternative - More Complex):**
Have factory return Either<String, User> (string error instead of Failure):
```dart
factory User.login(...) {
  if (email.isEmpty) return Left('Email cannot be empty');
  if (displayName.isEmpty) return Left('Display name cannot be empty');
  return Right(User(...));
}
```

**Recommendation:** Use Option A - move validation to use case layer

**Impact Check:**
After changing User entity, check these use cases:
- `lib/features/auth/domain/usecases/sign_in_with_email.dart` (line 28 calls User.login)
- `lib/features/auth/domain/usecases/register_with_email.dart` (calls User.register)

They should handle validation and return Either<Failure, User> properly.

---

## ✅ Fix Workflow

### Step 1: Fix BLoCs (Issues #1-3)
```bash
# For each BLoC file:
1. Read file
2. Change `extends Bloc<E, S>` to `extends EffectBloc<E, S>`
3. Verify no other changes needed (states already correct)
4. Save file
```

### Step 2: Fix User Entity (Issue #4)
```bash
1. Read lib/data/session/domain/entities/user.dart
2. Remove import 'package:health_duel/core/error/error.dart';
3. Remove validation logic from factory methods
4. Save file
```

### Step 3: Verify Use Cases Still Work
```bash
1. Read lib/features/auth/domain/usecases/sign_in_with_email.dart
2. Check if validation is handled at use case level
3. If not, add validation there (return Left(ValidationFailure(...)))
```

### Step 4: Verify Compilation
```bash
cd health_duel
flutter analyze
```

---

## 🚨 Important Notes

**DO NOT:**
- Change state classes (already correct)
- Change event classes
- Modify DI registration
- Touch repository implementations

**ONLY CHANGE:**
- BLoC base class (3 files)
- User entity validation logic (1 file)

**Total Files to Edit:** 4 files

---

## 📊 Success Criteria

Fix complete when:
- ✅ AuthBloc extends EffectBloc
- ✅ HealthBloc extends EffectBloc
- ✅ HomeBloc extends EffectBloc
- ✅ User entity has NO core/error import
- ✅ `flutter analyze` passes (or same 3 info as before)

---

## 📝 Reporting

When done, report:
1. Files changed (should be 4)
2. Any compilation errors
3. Flutter analyze result
4. Status: READY for re-review

---

**Fix priority: BLoCs first, then User entity. Good luck!** 🔧
