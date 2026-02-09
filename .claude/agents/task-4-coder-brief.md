# Task #4: Coder Agent Briefing - Port Core Infrastructure

**Agent Type:** Coder (general-purpose)
**Task:** Port 86 core files from reference to health_duel
**Duration Estimate:** 10-20 minutes
**Complexity:** Medium (large file copy with critical fixes)

---

## ✅ Pre-Flight Checklist

Before you start, confirm you've read:
- [x] `.claude/AGENT_CONTEXT.md` (master context)
- [x] `.claude/tasks/task-list.md` (Task #4 definition)
- [x] This briefing file
- [x] Required architecture documents (listed below)

---

## 🎯 Your Mission

Port **86 core files** from `reference_project/fintrack_lite/lib/core/` to `health_duel/lib/core/`.

**Good news:** All files already use `package:health_duel` imports, so you can copy them **verbatim** with ONE exception:
- ⚠️ **CRITICAL FIX:** `firebase_options.dart` has wrong iOS bundle ID (must fix)

This is the foundation that all features will build upon, so accuracy is critical.

---

## 📚 Required Reading

### Must Read (in order):

1. **`.claude/PROGRESS.md`** (Phase 2 summary)
   - Understand what Analyzer found (86 files, patterns)
   - Know the critical rebranding issue

2. **`health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md`** (full read)
   - Clean Architecture 3-layer structure
   - Module organization
   - EffectBloc pattern overview
   - DI registration order

3. **`health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md`** (full read)
   - EffectBloc 5-part system (Bloc, State, Effect, Registry, Listener)
   - Effect timestamp uniqueness
   - State props strategy (exclude effect)
   - Effect handler registration

4. **`health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md`** (full read)
   - Exception → Failure mapping pattern
   - ExceptionMapper usage
   - Repository error handling

5. **`health_duel/docs/00-foundation/PROJECT_GLOSSARY.md`** (skim)
   - Key terms: User, StepCount, Duel, Failure types, Effect types

### Reference Information:

6. **Task #1 Analyzer Output Summary:**
   ```
   Module Breakdown (86 files total):
   - bloc/ (18 files) - EffectBloc base classes, effects, handlers
   - presentation/ (33 files) - Shared widgets library
   - config/ (7 files) - AppConfig, Firebase options, storage keys
   - di/ (3 files) - Dependency injection setup
   - error/ (3 files) - Failure types, exception mapper
   - router/ (5 files) - GoRouter configuration
   - theme/ (9 files) - Design tokens, theme extensions
   - utils/ (6 files) - Extensions (string, context, datetime, list, num)
   - core.dart (1 file) - Barrel export

   Critical Finding:
   - firebase_options.dart has iOS bundle ID: com.example.fintrackLite
   - MUST CHANGE to: com.example.health_duel
   ```

---

## 🔧 Execution Steps

### Step 1: Verify Prerequisites
```bash
cd "C:\Work Stuff Personal\Project\new-health-duel"
ls health_duel/lib/core/  # Should show empty subdirs: bloc, config, di, etc.
ls reference_project/fintrack_lite/lib/core/  # Should show files
```

### Step 2: Port Core Modules (Copy Verbatim)

**Copy each module directory:**

```bash
# 1. BLoC module (18 files)
cp -r reference_project/fintrack_lite/lib/core/bloc/* health_duel/lib/core/bloc/

# 2. Presentation widgets (33 files)
cp -r reference_project/fintrack_lite/lib/core/presentation/* health_duel/lib/core/presentation/

# 3. Config module (7 files)
cp -r reference_project/fintrack_lite/lib/core/config/* health_duel/lib/core/config/

# 4. DI module (3 files)
cp -r reference_project/fintrack_lite/lib/core/di/* health_duel/lib/core/di/

# 5. Error module (3 files)
cp -r reference_project/fintrack_lite/lib/core/error/* health_duel/lib/core/error/

# 6. Router module (5 files)
cp -r reference_project/fintrack_lite/lib/core/router/* health_duel/lib/core/router/

# 7. Theme module (9 files)
cp -r reference_project/fintrack_lite/lib/core/theme/* health_duel/lib/core/theme/

# 8. Utils module (6 files)
cp -r reference_project/fintrack_lite/lib/core/utils/* health_duel/lib/core/utils/

# 9. Barrel file (1 file)
cp reference_project/fintrack_lite/lib/core/core.dart health_duel/lib/core/
```

### Step 3: Critical Fix - Firebase Options iOS Bundle ID

**File:** `health_duel/lib/core/config/firebase_options.dart`

**Find and replace:**
```dart
// OLD (WRONG):
iosBundleId: 'com.example.fintrackLite',

// NEW (CORRECT):
iosBundleId: 'com.example.health_duel',
```

**How to do it:**
1. Read the file: `Read health_duel/lib/core/config/firebase_options.dart`
2. Use Edit tool to replace the iosBundleId line
3. Verify the change with Read again

### Step 4: Verify File Count

```bash
# Count total Dart files in each module
find health_duel/lib/core -name "*.dart" -type f | wc -l
# Expected: 86 files

# Verify each module
find health_duel/lib/core/bloc -name "*.dart" | wc -l          # Expected: 18
find health_duel/lib/core/presentation -name "*.dart" | wc -l  # Expected: 33
find health_duel/lib/core/config -name "*.dart" | wc -l        # Expected: 7
find health_duel/lib/core/di -name "*.dart" | wc -l            # Expected: 3
find health_duel/lib/core/error -name "*.dart" | wc -l         # Expected: 3
find health_duel/lib/core/router -name "*.dart" | wc -l        # Expected: 5
find health_duel/lib/core/theme -name "*.dart" | wc -l         # Expected: 9
find health_duel/lib/core/utils -name "*.dart" | wc -l         # Expected: 6
find health_duel/lib/core -maxdepth 1 -name "*.dart" | wc -l   # Expected: 1 (core.dart)
```

### Step 5: Verify Imports (Spot Check)

**Check that imports use `package:health_duel` (should already be correct):**

```bash
# Sample: Check a few key files
grep "^import" health_duel/lib/core/bloc/effect_bloc.dart | head -5
grep "^import" health_duel/lib/core/di/injection.dart | head -5
grep "^import" health_duel/lib/core/router/app_router.dart | head -5

# None should have relative imports like '../'
# All should use 'package:health_duel/' or external packages
```

### Step 6: Verify No Reference to fintrack_lite

```bash
# Search for any remaining "fintrack" references (should only find fixed firebase_options)
grep -r "fintrack" health_duel/lib/core/ --include="*.dart"
# Expected: NO results (we fixed firebase_options)
```

---

## ✅ Success Criteria

Your task is **COMPLETE** when ALL of these are true:
- ✅ 86 Dart files exist in `health_duel/lib/core/`
- ✅ File count per module matches expected (see Step 4)
- ✅ `firebase_options.dart` iOS bundle ID is `com.example.health_duel`
- ✅ No "fintrack" strings remain in any core file
- ✅ All imports use `package:health_duel/...` (spot check)
- ✅ `core.dart` barrel file exists at root of core/

---

## 📊 Module Descriptions (What You're Porting)

### 1. **bloc/ (18 files)** - EffectBloc Pattern
Core of the effect system:
- `effect_bloc.dart` - Base BLoC with effect emission
- `ui_state.dart`, `ui_effect.dart` - Base state & effect classes
- `effect_clearable.dart` - Mixin for clearing effects
- Effect types: `feedback_effect.dart`, `navigation_effect.dart`, etc.
- `effect_registry.dart` - Type-safe effect handler registry
- `effect_listener.dart` - BlocListener wrapper for effects
- `app_bloc_observer.dart` - Debug logging observer

**Key Pattern:** EffectBloc 5-part system (see ADR-0004)

### 2. **presentation/ (33 files)** - Shared Widget Library
Reusable UI components:
- `connectivity/` - Online/offline detection
- `form/` - ValidatedTextField, PasswordTextField, validators
- `shimmer/` - Skeleton loading states
- `responsive/` - Adaptive layouts, breakpoints
- `error/` - FailureView, EmptyStateView, MessageBanner
- `dialog/` - AppDialog, FullscreenDialog, IconDialog
- Other: EffectListener, LiveTimeAgoText

**Key Pattern:** Presentation-only widgets (no business logic)

### 3. **config/ (7 files)** - Configuration
App configuration management:
- `app_config.dart` - Singleton configuration (dev/prod)
- `firebase_options.dart` - Firebase platform configs ⚠️ FIX THIS
- `storage_keys.dart` - Hive box keys
- `env/` - Environment variable definitions (envied package)

**Key Pattern:** Singleton initialization, flavor-based config

### 4. **di/ (3 files)** - Dependency Injection
GetIt service locator:
- `injection.dart` - Main DI initialization
- `core_module.dart` - Core module registration (storage, network, security)

**Key Pattern:** Registration order matters (core → features → router)

### 5. **error/ (3 files)** - Error Handling
Failure types and mapping:
- `failures.dart` - Sealed Failure class hierarchy
- `exception_mapper.dart` - CoreException → Failure mapping

**Key Pattern:** Exception isolation (see ADR-0002)

### 6. **router/ (5 files)** - Navigation
GoRouter configuration:
- `app_router.dart` - Router factory with auth guards
- `routes.dart` - Route paths and helpers
- `go_router_refresh.dart` - Reactive router refresh

**Key Pattern:** Auth state-based routing

### 7. **theme/ (9 files)** - Design System
Theme and design tokens:
- `app_theme.dart` - Material 3 theme configuration
- `extensions/app_colors_extension.dart` - Semantic colors
- `tokens/` - Design tokens (spacing, radius, durations)

**Key Pattern:** ThemeExtension for custom tokens

### 8. **utils/ (6 files)** - Extensions
Dart/Flutter extensions:
- `string_extensions.dart` - String utilities
- `context_extensions.dart` - BuildContext helpers
- `datetime_extensions.dart`, `list_extensions.dart`, `num_extensions.dart`
- `extensions.dart` - Barrel export

**Key Pattern:** Extension methods for cleaner code

### 9. **core.dart (1 file)** - Barrel Export
Single import point: `import 'package:health_duel/core/core.dart';`

---

## ❌ Common Mistakes to Avoid

1. **❌ Modifying imports:** Don't change imports. They're already correct (`package:health_duel`).

2. **❌ Forgetting firebase_options fix:** This is THE critical fix. Don't skip it.

3. **❌ Copying tests:** Only copy `lib/core/`, not `test/`. Tests are Task #10 (Phase 3).

4. **❌ Copying examples:** Don't copy `lib/core/examples/` if it exists. Only production code.

5. **❌ Breaking file structure:** Keep exact directory structure. Don't reorganize or rename.

6. **❌ Adding comments:** Don't add "ported by" comments or modify existing comments.

7. **❌ Format changes:** Don't run `dart format`. Keep files exactly as-is.

---

## 📊 Reporting Template

### If SUCCESS:
```
✅ Task #4 COMPLETED

Files ported: 86 Dart files
Modules: bloc, presentation, config, di, error, router, theme, utils, core.dart

File count verification:
- bloc/: 18 files ✓
- presentation/: 33 files ✓
- config/: 7 files ✓
- di/: 3 files ✓
- error/: 3 files ✓
- router/: 5 files ✓
- theme/: 9 files ✓
- utils/: 6 files ✓
- core.dart: 1 file ✓

Critical fixes applied:
✅ firebase_options.dart iOS bundle ID: com.example.health_duel

Import verification (spot check):
✅ All imports use package:health_duel/...
✅ No relative imports found
✅ No "fintrack" references found

Ready for Task #11 (Code & Architecture Review).
```

### If ISSUES FOUND:
```
⚠️ Task #4 COMPLETED WITH WARNINGS

[Describe any unexpected issues, missing files, or deviations]

Action needed: [what needs review or fixing]
```

---

## 🔍 Post-Port Verification Commands

Run these after porting to verify integrity:

```bash
# 1. Total file count
find health_duel/lib/core -name "*.dart" | wc -l

# 2. Check critical files exist
ls health_duel/lib/core/bloc/effect_bloc.dart
ls health_duel/lib/core/di/injection.dart
ls health_duel/lib/core/config/firebase_options.dart
ls health_duel/lib/core/core.dart

# 3. Verify firebase_options fix
grep "iosBundleId.*health_duel" health_duel/lib/core/config/firebase_options.dart

# 4. Check for fintrack references (should be none)
grep -r "fintrack" health_duel/lib/core/ --include="*.dart"

# 5. Sample import check
head -20 health_duel/lib/core/di/injection.dart | grep "^import"
```

---

## ⚠️ Important Notes

1. **Read-only reference:** Never modify files in `reference_project/`. Only read from there.

2. **Verbatim copy:** Copy files exactly as-is. Don't "improve" or refactor.

3. **One critical fix:** Only firebase_options.dart needs editing. Everything else is verbatim.

4. **Trust the Analyzer:** Analyzer verified all imports are correct. Don't second-guess.

5. **No code review yet:** Just port the files. Reviewer agent (Task #11) will check quality.

---

## 🎓 Background Knowledge

### Why These Files Matter
- **bloc/**: Foundation for all feature BLoCs (Auth, Home, Health, Duel)
- **presentation/**: Shared widgets used across all features
- **config/**: Required for app initialization (Firebase, DI, environment)
- **di/**: Must be initialized before any features load
- **error/**: Error handling used by all repositories
- **router/**: Navigation system for entire app
- **theme/**: Consistent design across all screens
- **utils/**: Helper functions used everywhere

### What Happens Next
After you complete:
- Lead agent will spawn Reviewer agent (Task #11) to check quality
- Reviewer will verify Clean Architecture boundaries
- Reviewer will check pattern adherence
- Then QA agent (Task #12) will run flutter analyze & build

---

## 🚀 Ready to Start?

1. ✅ I've read AGENT_CONTEXT.md
2. ✅ I've read this briefing
3. ✅ I've read ARCHITECTURE_OVERVIEW.md
4. ✅ I've read ADR-0004 (EffectBloc pattern)
5. ✅ I've read ADR-0002 (Exception isolation)
6. ✅ I understand the one critical fix (firebase_options)
7. ✅ I'm ready to port 86 files

**Good luck! Start copying and report back when done.** 🎯
