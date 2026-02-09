# Health Duel — Recreate & Continue Plan

## Context

**Health Duel** is a Flutter mobile app for social 24-hour step-count competitions. A reference implementation exists at `reference_project/fintrack_lite/` with completed auth, home, and health features (Phases 1-4). The directory is named `fintrack_lite` but all Dart source already uses `package:health_duel` (verified: 223 occurrences, 0 of `fintrack_lite`). We need to recreate the project properly branded as `health_duel/` and continue with the Duel feature (Phase 5).

**Key change from reference:** Use `https://github.com/arkariz/flutter-package-core` as a git dependency instead of local monorepo copy.

---

## Specialized Role-Based Agent Teams

### Agent Roles

| Role | Responsibility | When Used |
|------|---------------|-----------|
| **Lead Agent** (me) | Orchestrates all work, delegates tasks, makes architectural decisions, coordinates between agents | Always active |
| **Analyzer** | Deep-dives into reference code to extract exact implementations, identifies patterns, validates assumptions | Before coding phases |
| **Planner** | Designs feature architecture, entity relationships, API contracts, file structures | Before new features |
| **Coder** | Writes/ports code following the analyzed patterns and planned architecture | During implementation |
| **Reviewer** | Reviews design decisions, architecture alignment, code quality, pattern adherence, naming conventions, and Clean Architecture boundary violations | After coding phases |
| **QA** | Runs builds (`flutter build`), static analysis (`flutter analyze`), tests (`flutter test`), validates compilation and runtime correctness | After review passes |
| **Fixer** | Resolves issues found by Reviewer or QA — architecture misalignment, code smells, build errors, test failures, lint warnings | When issues are found |

### Workflow Per Phase

```
Analyzer → Planner → Coder(s) → Reviewer → QA → Fixer (if issues) → Reviewer/QA (re-verify)
   ↑                                                                          |
   └──────────────────────── Lead Agent orchestrates ─────────────────────────┘
```

---

## Execution Plan

### Phase 1: Analyze & Enhance Documentation (Documentation-First)

Documentation drives everything. Before writing any code, we analyze the reference project and create proper, enhanced documentation.

**Step 1 — Analyzer: Deep-Dive Reference Project**
- Read all existing docs (ADRs, PRD, planning, research, cheatsheet)
- Read core architecture code to understand patterns and decisions
- Read all feature implementations (auth, home, health)
- Identify gaps, inconsistencies, and areas needing documentation
- Document findings for the Planner

**Step 2 — Planner: Design Enhanced Documentation**
- Plan improved documentation structure
- Define what each document should cover
- Plan new ADRs needed (e.g., Duel feature, git dependency strategy)
- Plan updated roadmap reflecting recreated project + next phases

**Step 3 — Coder: Write Enhanced Documentation**
- Create `docs/` directory in new project root
- Write enhanced ADRs (port existing + add new ones)
- Write enhanced PRD
- Write updated roadmap and active tasks
- Write updated technical specs
- Update all references from `fintrack_lite` → `health_duel`

**Step 4 — Reviewer: Review Documentation**
- Verify docs accurately reflect the architecture
- Verify consistency across all documents
- Verify nothing critical from reference is missing
- Verify new content adds real value over reference docs

### Phase 2: Project Foundation & Core Port

With documentation as our guide, scaffold the project and port core infrastructure.

**Step 5 — Analyzer: Extract Core Implementation Details**
- Read all `core/` files from reference to extract exact code
- Map import chains and cross-references
- Identify platform config changes needed for rebranding

**Step 6 — Coder: Scaffold Project**
- `flutter create --org com.healthduel health_duel`
- Replace generated `pubspec.yaml` with reference version
- Update pubspec: change `flutter-package-core` path deps → git deps from `https://github.com/arkariz/flutter-package-core`
- Copy platform configs (`android/`, `ios/`, `web/`) from reference
- Rebrand: Android `applicationId`, iOS `bundleIdentifier`
- Copy `env/` directory for environment config

**Step 7 — QA: Validate Foundation**
- `flutter pub get` succeeds with git dependencies

**Step 8 — Coder: Port Core Infrastructure (~40 files)**
- Port `lib/core/bloc/` — EffectBloc, effects, observer
- Port `lib/core/config/` — AppConfig, env, firebase_options, storage_keys
- Port `lib/core/di/` — injection.dart, core_module.dart
- Port `lib/core/error/` — failures.dart, exception_mapper.dart
- Port `lib/core/router/` — app_router.dart, routes.dart, go_router_refresh.dart
- Port `lib/core/theme/` — app_theme.dart, extensions, tokens
- Port `lib/core/utils/` — all extensions
- Port `lib/core/presentation/widgets/` — all shared widgets

### Phase 3: Port Features

**Step 9 — Coder: Port Features (parallel agents)**

*Agent A — Session & Auth + Entry Points:*
- Port `lib/data/session/` (User entity, SessionRepo, UserModel, DataSource, DI)
- Port `lib/features/auth/` (full feature: domain, data, presentation, DI)
- Port `lib/main.dart` and `lib/app.dart`

*Agent B — Home & Health:*
- Port `lib/features/home/` (HomeBloc, HomePage, DI)
- Port `lib/features/health/` (entities, repo, HealthBloc, pages, widgets, DI)

**Step 10 — Coder: Port Tests**
- Port `test/helpers/` (mocks, fixtures, pump_app)
- Port all existing test files

**Step 11 — Reviewer: Code & Architecture Review**
- Verify Clean Architecture boundaries (no Flutter imports in domain)
- Verify import paths use `package:health_duel/...` consistently
- Verify DI module registration follows correct order
- Verify EffectBloc pattern adherence in all BLoCs
- Verify Either<Failure, T> pattern in all repositories

**Step 12 — QA: Full Verification**
- `flutter pub get`
- `flutter analyze` — zero issues
- `flutter test` — all tests pass
- `flutter build apk --debug` — compiles successfully

**Step 12a — Fixer (if needed): Resolve Issues**
- Fix any build errors, test failures, lint warnings
- Re-run Reviewer + QA cycle

### Phase 4: Build Duel Feature

**Step 13 — Planner: Design Duel Architecture**
- Design entities, repository contract, use cases
- Design Firestore schema
- Design DuelBloc states/events/effects
- Design UI pages and widget tree
- Output: detailed implementation spec for Coder

**Step 14 — Coder: Implement Duel Feature**
- Implement domain layer (entities, repository interface, use cases)
- Implement data layer (models, data sources, repository impl, DI)
- Implement presentation layer (BLoC, pages, widgets)
- Update `injection.dart`, `app_router.dart`, `home_page.dart`

**Step 15 — Coder: Write Duel Tests**
- Unit tests for entities and use cases
- BLoC tests for DuelBloc
- Widget tests for key pages

**Step 16 — Reviewer: Duel Code & Architecture Review**
- Verify entities follow same patterns as StepCount/User
- Verify repository maps exceptions → failures correctly
- Verify BLoC follows EffectBloc pattern with proper stream lifecycle
- Verify Clean Architecture boundary: no Firestore imports in domain

**Step 17 — QA: Duel Verification**
- `flutter analyze` — clean
- `flutter test` — all new + existing tests pass
- `flutter build apk --debug` — compiles

**Step 17a — Fixer (if needed): Resolve Issues**

---

## Key Coordination Points

| File | Touched By | Coordination |
|------|-----------|--------------|
| `pubspec.yaml` | Foundation, Duel phase | Git dep for flutter-package-core |
| `lib/core/di/injection.dart` | Core, Auth, Home, Health, Duel | Each feature registers its module |
| `lib/core/router/app_router.dart` | Core, Duel | Duel routes added in Phase 4 |
| `lib/main.dart` | Auth (entry point) | DI init + app launch |

---

## Verification Checkpoints

1. **After Phase 1**: Documentation is complete and enhanced
2. **After Phase 2-3**: `flutter analyze` clean, `flutter test` passes, `flutter build apk --debug` compiles
3. **After Phase 4**: Duel feature builds, tests pass, full flow works

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Git dep resolution for flutter-package-core | Pause and ask user for help if blocked — they will resolve it |
| Platform config rebranding (bundle IDs) | Carefully update build.gradle + Info.plist |
| DI registration order | Follow pattern: core → session → auth → home → health → duel → router |
| Duel real-time stream lifecycle | Cancel subscription in BLoC close() |
| Firebase config | Copy firebase_options.dart, update only bundle IDs |
