# Coder Agent A Briefing - Port Session & Auth Features

**Agent Type:** Coder (general-purpose)
**Task ID:** #5
**Duration Estimate:** 15-20 minutes
**Mode:** Background

---

## 🎯 Your Mission

Port Session data layer + Auth feature + Entry points from reference to health_duel.

**Source:** `C:\Work Stuff Personal\Project\new-health-duel\reference_project\fintrack_lite\`
**Target:** `C:\Work Stuff Personal\Project\new-health-duel\health_duel\`

---

## 📚 Required Reading

**CRITICAL - Read FIRST:**
1. `.claude/AGENT_CONTEXT.md` (master context)
2. `.claude/PROGRESS.md` (Phase 2 completed, Phase 3 starting)

**Architecture Docs:**
3. `health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md`
4. `health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md` (EffectBloc pattern)
5. `health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md` (Error handling)

---

## 📋 Files to Port

### 1. Session Data Layer (~7 files)
**Source:** `reference_project/fintrack_lite/lib/data/session/`
**Target:** `health_duel/lib/data/session/`

Files:
- `domain/entities/user.dart` - User entity
- `domain/repositories/session_repository.dart` - Repository interface
- `data/models/user_model.dart` - User model (Firestore serialization)
- `data/datasources/session_remote_data_source.dart` - Firestore data source
- `data/repositories/session_repository_impl.dart` - Repository implementation
- `di/session_module.dart` - DI registration
- `session.dart` - Barrel export

### 2. Auth Feature (~25 files)
**Source:** `reference_project/fintrack_lite/lib/features/auth/`
**Target:** `health_duel/lib/features/auth/`

**Structure:**
```
auth/
├── domain/
│   ├── entities/auth_user.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/ (login, register, logout, get_current_user)
├── data/
│   ├── models/auth_user_model.dart
│   ├── datasources/auth_remote_data_source.dart
│   └── repositories/auth_repository_impl.dart
├── presentation/
│   ├── bloc/ (AuthBloc - EffectBloc pattern)
│   ├── pages/ (LoginPage, RegisterPage)
│   └── widgets/ (auth forms, buttons)
├── di/auth_module.dart
└── auth.dart
```

### 3. Entry Points (2 files)
**Source:** `reference_project/fintrack_lite/lib/`
**Target:** `health_duel/lib/`

Files:
- `main.dart` - App entry point (DI init, Firebase init)
- `app.dart` - App widget (MaterialApp, router, theme)

---

## ✅ Porting Instructions

### Step 1: Verify Reference Files
```bash
cd reference_project/fintrack_lite
find lib/data/session -name "*.dart"
find lib/features/auth -name "*.dart"
```

### Step 2: Create Target Directories
```bash
cd health_duel
mkdir -p lib/data/session/domain/entities
mkdir -p lib/data/session/domain/repositories
mkdir -p lib/data/session/data/models
mkdir -p lib/data/session/data/datasources
mkdir -p lib/data/session/data/repositories
mkdir -p lib/data/session/di
mkdir -p lib/features/auth/{domain,data,presentation}/...
```

### Step 3: Copy Files Verbatim
- **NO MODIFICATIONS** needed - all imports already use `package:health_duel`
- Copy each file exactly as-is from reference to target
- Preserve directory structure

### Step 4: Verify Imports
- All imports should use `package:health_duel/...`
- NO relative imports for cross-module access
- External packages use `package:flutter_bloc/...`, etc.

---

## 🔍 Key Patterns to Follow

### AuthBloc - EffectBloc Pattern
**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Must have:**
- ✅ Extends `EffectBloc<AuthEvent, AuthState>`
- ✅ Uses `emitWithEffect()` for effects
- ✅ AuthState has `final UiEffect? effect` field
- ✅ AuthState mixin `EffectClearable<AuthState>`
- ✅ State props excludes effect

### Repository - Error Handling
**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Must have:**
- ✅ Returns `Either<Failure, T>`
- ✅ Wraps exceptions with `ExceptionMapper.toFailure()`
- ✅ No raw exceptions thrown

### DI Module
**File:** `lib/features/auth/di/auth_module.dart`

**Must have:**
- ✅ `registerAuthModule(GetIt getIt)` function
- ✅ Registers repository, use cases, BLoC
- ✅ Follows dependency order (data source → repo → use cases → BLoC)

---

## 🚨 Critical Notes

1. **NO CODE CHANGES** - Copy verbatim, all imports already correct
2. **Session FIRST** - Auth depends on session User entity
3. **DI Integration** - Auth module registers in `core/di/injection.dart` (already there, will work after files copied)
4. **Router Integration** - Routes reference auth pages in `core/router/app_router.dart` (already there, will work after files copied)

---

## 📊 Success Criteria

Task complete when:
- ✅ All session files copied (~7 files)
- ✅ All auth files copied (~25 files)
- ✅ main.dart and app.dart copied (2 files)
- ✅ Total: ~34 files ported
- ✅ No compilation errors expected (DI/router already reference these)

---

## 📝 Reporting

When done, report:
1. Total files ported
2. Any issues encountered
3. Status: READY for parallel agent (Coder B) to complete

---

**Start with session, then auth, then entry points. Good luck!** 🚀
