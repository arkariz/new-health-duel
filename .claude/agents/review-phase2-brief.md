# Reviewer Agent Briefing - Phase 2 Core Review

**Agent Type:** Reviewer (Explore agent)
**Task:** Review core infrastructure architecture & code quality
**Duration Estimate:** 10-15 minutes
**Complexity:** Medium (architectural analysis)

---

## ✅ Pre-Flight Checklist

Before you start, confirm you've read:
- [x] `.claude/AGENT_CONTEXT.md` (master context)
- [x] `.claude/PROGRESS.md` (current status)
- [x] This briefing file

---

## 🎯 Your Mission

Review the **85 core files** that were just ported from reference project to verify:
1. **Clean Architecture boundaries** are maintained
2. **Pattern adherence** (EffectBloc, error handling, DI)
3. **Code quality** (naming, documentation, structure)
4. **Import correctness** (package:health_duel usage)

**Context:** These files were copied verbatim from reference with ONE fix (firebase_options.dart iOS bundle ID). Features haven't been ported yet, so missing imports for auth/home/health are EXPECTED.

**Working Directory:** `C:\Work Stuff Personal\Project\new-health-duel\health_duel\lib\core\`

---

## 📚 Required Reading

### Must Read (in order):

1. **`.claude/PROGRESS.md`** (Phase 2 summary)
   - Understand what was ported (85 files)
   - Know the firebase_options fix applied
   - Context: Only core ported, features pending

2. **`health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md`**
   - Clean Architecture 3-layer structure
   - Module organization principles
   - Expected patterns

3. **`health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md`**
   - EffectBloc 5-part system
   - Effect timestamp uniqueness
   - State props strategy
   - Registry pattern

4. **`health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md`**
   - Exception → Failure mapping
   - Repository error handling pattern

5. **`health_duel/docs/00-foundation/PROJECT_GLOSSARY.md`**
   - Naming conventions (entities, effects, failures)

---

## 🔍 Review Checklist

### 1. Architecture Boundaries

**Check:** No layer violations in core infrastructure

**Files to Review:**
- `lib/core/bloc/` - Should only import Flutter BLoC, Equatable, no domain concepts
- `lib/core/presentation/` - Can import Flutter, core utilities, but no features
- `lib/core/error/` - Should be pure, no Flutter imports
- `lib/core/di/` - Can import everything (wires things together)
- `lib/core/router/` - Can import Flutter, GoRouter, references features (expected errors)

**Expected Findings:**
- ✅ Core modules don't depend on features (except di/ and router/ which reference them)
- ✅ No circular dependencies within core
- ⚠️ Missing feature imports in di/injection.dart and router/app_router.dart (EXPECTED - features not ported)

**Red Flags:**
- ❌ Core utilities importing from features
- ❌ Presentation widgets importing from features (except via router)
- ❌ Circular dependencies between core modules

---

### 2. EffectBloc Pattern (ADR-0004)

**Check:** EffectBloc 5-part system implemented correctly

**Files to Review:**

1. **Part 1: Base Bloc** - `lib/core/bloc/base/effect_bloc.dart`
   - ✅ Extends `Bloc<E, S>`
   - ✅ Has `emitWithEffect(Emitter<S> emit, S newState, UiEffect effect)` method
   - ✅ Casts state to `EffectClearable`

2. **Part 2: Base State** - `lib/core/bloc/base/state/ui_state.dart`
   - ✅ Extends `Equatable`
   - ✅ Has `final UiEffect? effect` field
   - ✅ Mixin `EffectClearable<T>` with `clearEffect()` and `withEffect()`
   - ✅ Props excludes effect (prevents widget rebuilds)
   - ✅ Custom `==` operator includes effect comparison

3. **Part 3: Base Effect** - `lib/core/bloc/base/effect/ui_effect.dart`
   - ✅ Extends `Equatable`
   - ✅ Has unique timestamp (`int _timestamp`)
   - ✅ Constructor auto-assigns timestamp
   - ✅ Property `effectId` for debugging

4. **Part 4: Effect Types** - `lib/core/bloc/effect/`
   - ✅ Concrete effects: `ShowSnackBarEffect`, `NavigateGoEffect`, `ShowDialogEffect`
   - ✅ Hierarchy: `FeedbackEffect`, `NavigationEffect`, `InteractiveEffect`
   - ✅ Each effect is immutable with const constructors

5. **Part 5: Registry & Listener**
   - `lib/core/bloc/effect/effect_registry.dart` - Registry implementation
   - `lib/core/presentation/widgets/effect_listener.dart` - Listener widget
   - ✅ Type-safe handler registration
   - ✅ Listener dispatches to registry

**Red Flags:**
- ❌ Effect without timestamp
- ❌ State props including effect
- ❌ Missing EffectClearable mixin
- ❌ Effect not extending UiEffect

---

### 3. Error Handling Pattern (ADR-0002)

**Check:** Exception isolation correctly implemented

**Files to Review:**

1. **`lib/core/error/failures.dart`**
   - ✅ Sealed `Failure` base class
   - ✅ Concrete failures: NetworkFailure, ServerFailure, AuthFailure, etc.
   - ✅ Each failure extends Equatable
   - ✅ Failures are immutable

2. **`lib/core/error/exception_mapper.dart`**
   - ✅ Static method `toFailure(CoreException e)`
   - ✅ Exhaustive switch on exception types
   - ✅ Maps to appropriate Failure types
   - ✅ `getUserMessage(Failure)` for user-friendly errors

**Expected Pattern:**
```dart
// Repositories should use Either<Failure, T>
Either<Failure, User> result = await repository.getUser();
// Exceptions mapped via ExceptionMapper.toFailure()
```

**Red Flags:**
- ❌ Throwing exceptions instead of returning Failure
- ❌ Non-exhaustive exception mapping
- ❌ Failure types not extending base Failure class

---

### 4. Dependency Injection (GetIt)

**Check:** DI registration order and module pattern

**Files to Review:**

1. **`lib/core/di/injection.dart`**
   - ✅ `initializeDependencies()` function
   - ✅ Firebase initialization first
   - ✅ `registerCoreModule()` called
   - ✅ `await getIt.allReady()` for async deps
   - ✅ Feature modules registered: session → auth → home → health
   - ✅ Router registered last (depends on AuthBloc)

2. **`lib/core/di/core_module.dart`**
   - ✅ Storage module (Hive)
   - ✅ Network module (Dio)
   - ✅ Security module (AES)
   - ✅ ConnectivityCubit as lazy singleton

**Expected Order:**
```
Firebase.initializeApp()
  ↓
registerCoreModule() (storage, network, security)
  ↓
await getIt.allReady()
  ↓
registerSessionModule()
  ↓
registerAuthModule()
  ↓
registerHomeModule(), registerHealthModule()
  ↓
_registerRouter() (depends on AuthBloc)
```

**Red Flags:**
- ❌ Wrong registration order
- ❌ Not waiting for async dependencies
- ❌ Circular dependencies in DI graph
- ❌ Missing modules

**Note:** Missing feature imports (auth, home, health) are EXPECTED - features not ported yet.

---

### 5. Router Architecture

**Check:** GoRouter setup with auth guards

**Files to Review:**

1. **`lib/core/router/routes.dart`**
   - ✅ `AppRoutes` class with route constants
   - ✅ Public routes: `/login`, `/register`
   - ✅ Protected routes: `/home`, `/health`, `/settings`
   - ✅ Helper methods: `duelPath(id)`, `invitePath(code)`
   - ✅ `isPublicRoute(path)` checker

2. **`lib/core/router/app_router.dart`**
   - ✅ `createAppRouter(AuthBloc authBloc)` factory
   - ✅ Auth redirect logic
   - ✅ `GoRouterRefreshStream(authBloc.stream)` for reactive updates
   - ✅ Route definitions with BlocProvider wrappers

3. **`lib/core/router/go_router_refresh.dart`**
   - ✅ Reactive stream for router refresh

**Expected Auth Logic:**
```
- Loading (AuthInitial|AuthLoading) → no redirect
- Not authenticated + protected route → /login?redirect={encoded}
- Authenticated + public route → /home (or redirect param)
```

**Red Flags:**
- ❌ No auth guards on protected routes
- ❌ Missing redirect parameter handling
- ❌ No reactive refresh on auth state changes

**Note:** Missing AuthBloc, pages imports are EXPECTED - features not ported yet.

---

### 6. Theme & Design System

**Check:** Material 3 theme with design tokens

**Files to Review:**

1. **`lib/core/theme/app_theme.dart`**
   - ✅ Light and dark color schemes
   - ✅ Material 3 (`useMaterial3: true`)
   - ✅ Google Fonts (Inter)
   - ✅ Theme extensions registered

2. **`lib/core/theme/extensions/app_colors_extension.dart`**
   - ✅ Semantic colors (success, warning, info)
   - ✅ Utility colors (cardBackground, divider, shimmer)
   - ✅ Static instances: `.light`, `.dark`
   - ✅ Context extension: `context.appColors`

3. **`lib/core/theme/tokens/`**
   - ✅ `AppSpacing` - spacing scale (xs, sm, md, lg, xl, xxl, xxxl)
   - ✅ `AppRadius` - border radius tokens
   - ✅ `AppDurations` - animation durations (fast, normal, slow)

**Red Flags:**
- ❌ Hardcoded colors/spacing in widgets
- ❌ Missing theme extensions
- ❌ No dark mode support

---

### 7. Presentation Widgets

**Check:** Reusable widget library follows patterns

**Files to Review:**

Sample key widgets:
1. **`lib/core/presentation/widgets/effect_listener.dart`**
   - ✅ Wraps BlocListener for effects
   - ✅ Dispatches to EffectRegistry

2. **`lib/core/presentation/widgets/form/validated_text_field.dart`**
   - ✅ Reusable form component
   - ✅ Validation support

3. **`lib/core/presentation/widgets/error/failure_view.dart`**
   - ✅ Displays Failure objects with styling

**Expected Patterns:**
- ✅ Widgets are stateless where possible
- ✅ No business logic in widgets (only presentation)
- ✅ Reusable, composable components
- ✅ Proper use of context extensions

**Red Flags:**
- ❌ Business logic in presentation widgets
- ❌ Direct BLoC access without BlocProvider
- ❌ Hardcoded strings (should use localization keys)

---

### 8. Code Quality

**Check:** General code quality standards

**Spot Check Files:**
- `lib/core/bloc/base/effect_bloc.dart`
- `lib/core/di/injection.dart`
- `lib/core/error/exception_mapper.dart`
- `lib/core/presentation/widgets/effect_listener.dart`

**Quality Criteria:**
- ✅ Clear documentation comments
- ✅ Consistent naming (camelCase, PascalCase)
- ✅ Immutable classes (final fields, const constructors)
- ✅ Type safety (no dynamic, proper generics)
- ✅ Proper error handling (no empty catches)

**Red Flags:**
- ❌ Missing documentation on public APIs
- ❌ Inconsistent naming conventions
- ❌ Use of `dynamic` where types are known
- ❌ Empty catch blocks
- ❌ TODO comments without issue tracking

---

### 9. Import Verification

**Check:** All imports use correct package paths

**Spot Check:**
```bash
# Sample key files
lib/core/di/injection.dart
lib/core/router/app_router.dart
lib/core/bloc/base/effect_bloc.dart
lib/core/error/exception_mapper.dart
```

**Expected:**
- ✅ Core imports: `package:health_duel/core/...`
- ✅ External packages: `package:flutter_bloc/...`, `package:get_it/...`
- ✅ No relative imports for cross-module access
- ⚠️ Missing feature imports (EXPECTED - features not ported yet)

**Red Flags:**
- ❌ Relative imports like `../../../core/...`
- ❌ Wrong package name (should be `health_duel` not `fintrack_lite`)

---

### 10. Critical Fix Verification

**Check:** Firebase options iOS bundle ID was fixed correctly

**File:** `lib/core/config/firebase_options.dart`

**Expected:**
```dart
static const FirebaseOptions ios = FirebaseOptions(
  // ...
  iosBundleId: 'com.example.health_duel',  // ✅ CORRECT
);
```

**Red Flag:**
- ❌ `iosBundleId: 'com.example.fintrackLite'` (WRONG - not fixed)

---

## 📊 Reporting Template

### Success Report:
```markdown
✅ PHASE 2 CORE REVIEW COMPLETED

## Architecture Review

### Clean Architecture Boundaries
[✅/⚠️/❌] Core modules don't depend on features
[✅/⚠️/❌] No circular dependencies
[Details...]

### EffectBloc Pattern (ADR-0004)
[✅/⚠️/❌] Part 1: Base Bloc implemented correctly
[✅/⚠️/❌] Part 2: Base State with EffectClearable mixin
[✅/⚠️/❌] Part 3: Base Effect with timestamp
[✅/⚠️/❌] Part 4: Effect type hierarchy
[✅/⚠️/❌] Part 5: Registry & Listener
[Details...]

### Error Handling (ADR-0002)
[✅/⚠️/❌] Failure hierarchy implemented
[✅/⚠️/❌] Exception mapper comprehensive
[Details...]

### Dependency Injection
[✅/⚠️/❌] Registration order correct
[✅/⚠️/❌] Module pattern followed
[✅/⚠️/❌] Async dependencies handled
[Details...]

### Router Architecture
[✅/⚠️/❌] Auth guards implemented
[✅/⚠️/❌] Route definitions correct
[✅/⚠️/❌] Reactive refresh configured
[Details...]

### Theme & Design System
[✅/⚠️/❌] Material 3 configured
[✅/⚠️/❌] Design tokens defined
[✅/⚠️/❌] Theme extensions working
[Details...]

### Code Quality
[✅/⚠️/❌] Documentation quality: [Score/10]
[✅/⚠️/❌] Naming conventions: [Score/10]
[✅/⚠️/❌] Type safety: [Score/10]
[✅/⚠️/❌] Immutability: [Score/10]
[Details...]

### Import Verification
[✅/⚠️/❌] All imports use package:health_duel
[✅/⚠️/❌] No relative imports for cross-module
[⚠️ EXPECTED] Missing feature imports (auth, home, health not ported)
[Details...]

### Critical Fix
[✅/❌] firebase_options.dart iOS bundle ID: com.example.health_duel

## Summary

**Overall Status:** [✅ APPROVED / ⚠️ APPROVED WITH NOTES / ❌ CHANGES REQUIRED]

**Critical Issues:** [Count]
[List if any...]

**Warnings:** [Count]
[List if any...]

**Recommendations:**
[List improvements or notes...]

**Ready for Phase 3:** [YES/NO]
[Justification...]
```

---

## 🚨 Important Notes

1. **Expected Errors:** Missing feature imports (auth, home, health, session) are EXPECTED and NOT issues.

2. **Focus on Core:** Only review lib/core/ files. Don't worry about missing features.

3. **Pattern Compliance:** The reference project is production-ready. Look for pattern violations, not style preferences.

4. **Red Flags Only:** Don't nitpick. Report only critical issues or pattern violations.

5. **Be Thorough:** This is architectural review, not code review. Focus on structure, not syntax.

---

## 🎯 Success Criteria

Review is COMPLETE when you've:
- ✅ Checked all 10 review areas
- ✅ Verified EffectBloc 5-part system
- ✅ Verified error handling pattern
- ✅ Verified DI registration order
- ✅ Spot-checked code quality (5-10 files)
- ✅ Verified firebase_options fix
- ✅ Generated comprehensive report
- ✅ Provided clear recommendation (approve/fix)

---

**Good luck! Focus on architecture, not perfection.** 🏗️
