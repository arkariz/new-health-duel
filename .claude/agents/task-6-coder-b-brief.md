# Coder Agent B Briefing - Port Home & Health Features

**Agent Type:** Coder (general-purpose)
**Task ID:** #6
**Duration Estimate:** 15-20 minutes
**Mode:** Background

---

## 🎯 Your Mission

Port Home and Health features from reference to health_duel.

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

### 1. Home Feature (~10 files)
**Source:** `reference_project/fintrack_lite/lib/features/home/`
**Target:** `health_duel/lib/features/home/`

**Structure:**
```
home/
├── presentation/
│   ├── bloc/home_bloc.dart (EffectBloc)
│   ├── bloc/home_event.dart
│   ├── bloc/home_state.dart
│   ├── pages/home_page.dart (Main navigation hub)
│   └── widgets/ (home-specific widgets)
├── di/home_module.dart
└── home.dart (barrel export)
```

**Note:** Home feature is simpler - mainly presentation layer with navigation.

### 2. Health Feature (~20 files)
**Source:** `reference_project/fintrack_lite/lib/features/health/`
**Target:** `health_duel/lib/features/health/`

**Structure:**
```
health/
├── domain/
│   ├── entities/
│   │   ├── step_count.dart (Daily step data)
│   │   └── health_permission_status.dart
│   ├── repositories/health_repository.dart
│   └── usecases/
│       ├── get_daily_steps.dart
│       ├── request_health_permissions.dart
│       └── sync_health_data.dart
├── data/
│   ├── models/
│   │   ├── step_count_model.dart (Firestore serialization)
│   │   └── health_permission_status_model.dart
│   ├── datasources/
│   │   ├── health_local_data_source.dart (Health plugin)
│   │   └── health_remote_data_source.dart (Firestore)
│   └── repositories/health_repository_impl.dart
├── presentation/
│   ├── bloc/ (HealthBloc - EffectBloc pattern)
│   ├── pages/ (HealthDashboardPage, PermissionPage)
│   └── widgets/ (step charts, permission prompts)
├── di/health_module.dart
└── health.dart
```

---

## ✅ Porting Instructions

### Step 1: Verify Reference Files
```bash
cd reference_project/fintrack_lite
find lib/features/home -name "*.dart"
find lib/features/health -name "*.dart"
```

### Step 2: Create Target Directories
```bash
cd health_duel
mkdir -p lib/features/home/presentation/{bloc,pages,widgets}
mkdir -p lib/features/home/di
mkdir -p lib/features/health/domain/{entities,repositories,usecases}
mkdir -p lib/features/health/data/{models,datasources,repositories}
mkdir -p lib/features/health/presentation/{bloc,pages,widgets}
mkdir -p lib/features/health/di
```

### Step 3: Copy Files Verbatim
- **NO MODIFICATIONS** needed - all imports already use `package:health_duel`
- Copy each file exactly as-is from reference to target
- Preserve directory structure

### Step 4: Verify Imports
- All imports should use `package:health_duel/...`
- NO relative imports for cross-module access
- External packages: `package:flutter_bloc/...`, `package:health/...`

---

## 🔍 Key Patterns to Follow

### HomeBloc - EffectBloc Pattern
**File:** `lib/features/home/presentation/bloc/home_bloc.dart`

**Must have:**
- ✅ Extends `EffectBloc<HomeEvent, HomeState>`
- ✅ Uses `emitWithEffect()` for navigation effects
- ✅ HomeState with `final UiEffect? effect` field
- ✅ Mixin `EffectClearable<HomeState>`

### HealthBloc - EffectBloc Pattern
**File:** `lib/features/health/presentation/bloc/health_bloc.dart`

**Must have:**
- ✅ Extends `EffectBloc<HealthEvent, HealthState>`
- ✅ Handles permission requests, step syncing
- ✅ Real-time step count updates
- ✅ Proper stream lifecycle (cancel in close())

### Health Repository - Error Handling
**File:** `lib/features/health/data/repositories/health_repository_impl.dart`

**Must have:**
- ✅ Returns `Either<Failure, T>`
- ✅ Wraps health plugin exceptions with `ExceptionMapper.toFailure()`
- ✅ Handles permission denied scenarios

### DI Modules
**Files:**
- `lib/features/home/di/home_module.dart`
- `lib/features/health/di/health_module.dart`

**Must have:**
- ✅ `registerHomeModule(GetIt getIt)` / `registerHealthModule(GetIt getIt)`
- ✅ Proper dependency registration order
- ✅ Health: data source → repo → use cases → BLoC

---

## 🚨 Critical Notes

1. **NO CODE CHANGES** - Copy verbatim, all imports already correct
2. **Health Plugin** - Uses `package:health/health.dart` for step tracking
3. **Firestore Integration** - Health syncs daily steps to Firestore
4. **DI Integration** - Both modules register in `core/di/injection.dart` (already there)
5. **Router Integration** - Routes reference pages in `core/router/app_router.dart` (already there)

---

## 📊 Success Criteria

Task complete when:
- ✅ All home files copied (~10 files)
- ✅ All health files copied (~20 files)
- ✅ Total: ~30 files ported
- ✅ No compilation errors expected (DI/router already reference these)

---

## 📝 Reporting

When done, report:
1. Total files ported (breakdown by feature)
2. Any issues encountered
3. Status: READY for Test porting phase

---

**Start with home, then health. Good luck!** 🚀
