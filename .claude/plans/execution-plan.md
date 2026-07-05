# Health Duel — Recreate & Continue Plan

> **Last reviewed:** 2026-07-05
> **Legend:** ✅ Done · ⚠️ Partial · ❌ Not started

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

### ✅ Phase 1: Analyze & Enhance Documentation (Documentation-First)

Documentation drives everything. Before writing any code, we analyze the reference project and create proper, enhanced documentation.

**✅ Step 1 — Analyzer: Deep-Dive Reference Project**
- Read all existing docs (ADRs, PRD, planning, research, cheatsheet)
- Read core architecture code to understand patterns and decisions
- Read all feature implementations (auth, home, health)
- Identify gaps, inconsistencies, and areas needing documentation
- Document findings for the Planner

**✅ Step 2 — Planner: Design Enhanced Documentation**
- Plan improved documentation structure
- Define what each document should cover
- Plan new ADRs needed (e.g., Duel feature, git dependency strategy)
- Plan updated roadmap reflecting recreated project + next phases

**✅ Step 3 — Coder: Write Enhanced Documentation**
- Create `docs/` directory in new project root → `health_duel/docs/` (12 dirs)
- Write enhanced ADRs (port existing + add new ones) → ADR 0000–0008 tersedia
- Write enhanced PRD
- Write updated roadmap and active tasks
- Write updated technical specs
- Update all references from `fintrack_lite` → `health_duel`

**✅ Step 4 — Reviewer: Review Documentation**
- Verify docs accurately reflect the architecture
- Verify consistency across all documents
- Verify nothing critical from reference is missing
- Verify new content adds real value over reference docs

### ✅ Phase 2: Project Foundation & Core Port

With documentation as our guide, scaffold the project and port core infrastructure.

**✅ Step 5 — Analyzer: Extract Core Implementation Details**
- Read all `core/` files from reference to extract exact code
- Map import chains and cross-references
- Identify platform config changes needed for rebranding

**✅ Step 6 — Coder: Scaffold Project**
- `flutter create --org com.healthduel health_duel`
- Replace generated `pubspec.yaml` with reference version
- Update pubspec: change `flutter-package-core` path deps → git deps from `https://github.com/arkariz/flutter-package-core`
- Copy platform configs (`android/`, `ios/`, `web/`) from reference
- Rebrand: Android `applicationId`, iOS `bundleIdentifier`
- Copy `env/` directory for environment config

**✅ Step 7 — QA: Validate Foundation**
- `flutter pub get` succeeds with git dependencies

**✅ Step 8 — Coder: Port Core Infrastructure (~40 files)**
- Port `lib/core/bloc/` — EffectBloc, effects, observer
- Port `lib/core/config/` — AppConfig, env, firebase_options, storage_keys
- Port `lib/core/di/` — injection.dart, core_module.dart
- Port `lib/core/error/` — failures.dart, exception_mapper.dart
- Port `lib/core/router/` — app_router.dart, routes.dart, go_router_refresh.dart
- Port `lib/core/theme/` — app_theme.dart, extensions, tokens
- Port `lib/core/utils/` — all extensions
- Port `lib/core/presentation/widgets/` — all shared widgets

### ✅ Phase 3: Port Features

**✅ Step 9 — Coder: Port Features (parallel agents)**

*Agent A — Session & Auth + Entry Points:*
- Port `lib/data/session/` (User entity, SessionRepo, UserModel, DataSource, DI)
- Port `lib/features/auth/` (full feature: domain, data, presentation, DI)
- Port `lib/main.dart` and `lib/app.dart`

*Agent B — Home & Health:*
- Port `lib/features/home/` (HomeBloc, HomePage, DI)
- Port `lib/features/health/` (entities, repo, HealthBloc, pages, widgets, DI)

**⚠️ Step 10 — Coder: Port Tests**
- ✅ Port `test/helpers/` (mocks, fixtures, pump_app)
- ✅ Port auth tests (`test/features/auth/` — 2 test files, 42 tests total)
- ❌ Port home tests — belum ada
- ❌ Port health tests — belum ada

**✅ Step 11 — Reviewer: Code & Architecture Review**
- Verify Clean Architecture boundaries (no Flutter imports in domain)
- Verify import paths use `package:health_duel/...` consistently
- Verify DI module registration follows correct order
- Verify EffectBloc pattern adherence in all BLoCs
- Verify Either<Failure, T> pattern in all repositories

**✅ Step 12 — QA: Full Verification**
- `flutter pub get` ✅
- `flutter analyze` — 0 issues ✅
- `flutter test` — 42/42 tests pass ✅
- `flutter build apk --debug` — compiles successfully ✅

**Step 12a — Fixer (if needed): Resolve Issues**
- ✅ Dijalankan — semua isu terselesaikan (commit `71d41ae`)

### ⚠️ Phase 4: Build Duel Feature

**✅ Step 13 — Planner: Design Duel Architecture**
- Design entities, repository contract, use cases → `.claude/designs/phase-4-duel-architecture.md`
- Design Firestore schema
- Design DuelBloc states/events/effects
- Design UI pages and widget tree
- Output: detailed implementation spec for Coder

**⚠️ Step 14 — Coder: Implement Duel Feature**
- ✅ Implement domain layer (entities, repository interface, use cases) — 9 use cases
- ✅ Implement data layer (models, data sources, repository impl, DI)
- ✅ Implement `DuelBloc` (active duel real-time watch, health sync, countdown)
- ✅ Implement UI screens — 4 screens, 4 widgets (sports-energy redesign included)
- ✅ Update `injection.dart`, `app_router.dart`, `home_page.dart`
- ✅ **`DuelListBloc`** — dibuat di Phase 6
- ✅ **`create_duel_screen.dart`**: BLoC dispatch, real opponent data dari Firestore — dibuat di Phase 6
- ✅ **`duel_list_screen.dart`**: 3 tab (Active/Pending/History) wire ke `DuelListBloc` — dibuat di Phase 6
- ✅ **`duel_repository_impl.dart`**: `createDuel` fetch challenger name dari `SessionRepository` — dibuat di Phase 6
- ✅ **`duel_side_effect.dart`**: leader name resolve dari `Duel.challengerName`/`challengedName` — dibuat di Phase 6

**❌ Step 15 — Coder: Write Duel Tests**
- Unit tests untuk use cases — belum ada
- BLoC tests untuk `DuelBloc` dan `DuelListBloc` — belum ada
- Widget tests untuk key pages — belum ada

**✅ Step 16 — Reviewer: Duel Code & Architecture Review**
- Verify entities follow same patterns as StepCount/User
- Verify repository maps exceptions → failures correctly
- Verify BLoC follows EffectBloc pattern with proper stream lifecycle
- Verify Clean Architecture boundary: no Firestore imports in domain

**⚠️ Step 17 — QA: Duel Verification**
- `flutter analyze` — 0 issues ✅
- `flutter test` — 42/42 pass ✅ *(hanya auth tests — duel belum ditest)*
- `flutter build apk --debug` — compiles ✅

**Step 17a — Fixer (if needed): Resolve Issues**
- ✅ Dijalankan — semua analyzer issues terselesaikan (commit `71d41ae`)

---

### ✅ Phase 6: Complete Duel Feature (Rework Step 14) — DONE 2026-02-28

Gap yang ditemukan saat review: `DuelListBloc` tidak pernah dibuat, menyebabkan
semua list screen tidak functional. Perlu diselesaikan sebelum testing.

**✅ Step 6.1 — Coder: Buat `DuelListBloc`**
- Events: `DuelListLoadRequested`, `DuelAcceptRequested`, `DuelDeclineRequested`
- States: `DuelListInitial`, `DuelListLoading`, `DuelListLoaded`, `DuelListError`
- `DuelListLoaded` berisi `activeDuels`, `pendingDuels`, `historyDuels`
- Side effects: `ShowSnackBarEffect` untuk accept/decline success/fail
- Gunakan use cases: `GetActiveDuels`, `GetPendingDuels`, `GetDuelHistory`, `AcceptDuel`, `DeclineDuel`
- Register di `duel_module.dart`

**✅ Step 6.2 — Coder: Wire `DuelListBloc` ke screens**
- `duel_list_screen.dart`: ganti `_EmptyState` statis dengan `BlocBuilder<DuelListBloc, DuelListState>`
  di ketiga tab (Active, Pending, History) — gunakan commented code yang sudah ada sebagai guide
- Provide `DuelListBloc` via `BlocProvider` di screen atau di router

**✅ Step 6.3 — Coder: Buat & wire `CreateDuelBloc` di `create_duel_screen.dart`**
- Pilihan A dipilih: `CreateDuelBloc` tersendiri dengan event `CreateDuelSubmitted`
- Fetches challenger name dari `SessionRepository` sebelum submit
- Friend list awalnya mock — diselesaikan di Step 6.6

**✅ Step 6.4 — Coder: Resolve user name di data layer**
- `duel_repository_impl.dart` `createDuel`: inject `SessionRepository`, fetch `getCurrentUser()`,
  gunakan `displayName` untuk `challengerName` sebelum call datasource
- `duel_side_effect.dart`: resolve leader name dari `Duel` entity (gunakan field `challengerName`/`challengedName` yang sudah ada di entity)

**✅ Step 6.5 — QA: Verifikasi ulang**
- `flutter analyze` — 0 issues ✅
- `flutter test` — 42/42 pass ✅
- `flutter build apk --debug` — belum dijalankan session ini

**✅ Step 6.6 — Coder: Real opponent data di `create_duel_screen.dart`**
- Buat `GetOpponents` use case — query `users` Firestore collection, exclude current user
- Tambah `getOpponents(excludeUserId)` ke `DuelFirestoreDataSource`, `DuelRepository`, `DuelRepositoryImpl`
- Update `CreateDuelEvent` dengan `CreateDuelOpponentsRequested(currentUserId)`
- Update `CreateDuelState` dengan `CreateDuelLoadingOpponents`, `CreateDuelReady(opponents)`, `CreateDuelSubmitting(opponents)`
- Update `CreateDuelBloc` handle opponent loading
- Tulis ulang `create_duel_screen.dart`: hapus mock `_Friend`, gunakan `UserModel` real
- Daftarkan `GetOpponents` di `duel_module.dart`
- Buat `firestore.indexes.json` dengan 3 composite index untuk query Firestore yang butuh index
- `flutter analyze` — 0 issues ✅

---

### ✅ Phase 5: UI Redesign — Sports-Energy Aesthetic *(bonus, di luar plan original)*

**✅ Step UI-1 — Design Tokens**
- Update color palette, typography, spacing ke sports-energy dark theme

**✅ Step UI-2 — Auth Screens Redesign**
- Redesign login & register screens

**✅ Step UI-3 — Home Screen Redesign**
- Redesign home dashboard, widget extraction per section

**✅ Step UI-4 — Duel Screens Redesign**
- Redesign Active, List, Create, Result screens

**✅ Step UI-5 — Navigation Wiring**
- Wire semua duel screens ke app navigation flow

---

### ✅ Phase 7: Friends Feature — DONE 2026-07-05 (commit `b005462`)

Fitur sosial: kelola daftar teman & cari pemain. Di luar plan original, ditambahkan
agar alur "tantang teman" lebih natural daripada memilih dari semua user acak.

**✅ Step 7.1 — Friends feature (Clean Architecture)**
- Domain: `FriendRepository` + use cases `GetFriends`, `AddFriend`, `RemoveFriend`, `SearchUsers`
- Data: `FriendFirestoreDataSource` (subcollection `users/{id}/friends`) + `FriendRepositoryImpl`
- Presentation: `FriendsBloc` (EffectBloc) + `FriendsScreen` (search, add, remove, challenge)
- DI: `friends_module.dart`, barrel `friends.dart`

**✅ Step 7.2 — Wiring**
- `injection.dart` → `registerFriendsModule()`
- `routes.dart` + `app_router.dart` → route `/friends`
- Home quick-action card → navigasi ke Friends

**✅ Step 7.3 — Integrasi ke Create Duel**
- `CreateDuelBloc` sumber lawan dari `GetFriends` (menggantikan `GetOpponents`)
- `duel_module` wire `GetFriends` ke `CreateDuelBloc`

**✅ Step 7.4 — Refactor pendukung**
- Ekstrak widget arena duel → `duel_arena_widgets.dart`; ramping `active_duel_screen`, `duel_card`, `active_duels_section`
- Hapus `home_dummy`; rework `home_page` + hero/quick-action sections
- Fix `app_theme` `CardTheme` → `CardThemeData` (Flutter SDK terbaru)

**⚠️ Belum: test Friends** — `test/features/friends/` masih kosong

---

### ❌ Phase 8: Create Duel — Toggle Friends / All Players (PLANNED)

> Plan detail: `.claude/plans/create-duel-opponent-toggle.md` (disetujui, belum dikerjakan)

User ingin tetap bisa menantang orang random. `GetOpponents` **dipertahankan**.
Create Duel akan punya toggle **[ Friends | All Players ]**:
- Friends → `GetFriends`; All Players → `GetOpponents`
- WIP: `create_duel_event.dart` sudah ditambah `enum OpponentSource` (belum di-commit)
- Sisa: `create_duel_bloc` (inject `GetOpponents`, branch source), `duel_module` (register ulang `GetOpponents`), `create_duel_screen` (SegmentedButton)

**Backlog review Friends (terpisah):**
- Debounce search (query Firestore tiap keystroke)
- Preselect teman saat klik "Challenge" dari layar Friends (konteks teman hilang)
- Test unit/bloc Friends & Duel (Step 15 masih pending)

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

1. ✅ **After Phase 1**: Documentation is complete and enhanced
2. ✅ **After Phase 2-3**: `flutter analyze` clean, `flutter test` passes, `flutter build apk --debug` compiles
3. ⚠️ **After Phase 4**: Duel feature builds and analyze clean ✅ — `DuelListBloc` belum ada, screens tidak functional ❌, tests belum ditulis ❌
4. ✅ **After Phase 6**: Duel feature fully functional — semua screens wire ke BLoC, real opponent data dari Firestore, 0 TODO/commented code (analyze clean ✅, tests pass ✅)
   - Pending: `firebase deploy --only firestore:indexes` untuk deploy composite indexes
   - Pending: duel tests belum ditulis (Step 15)
5. ✅ **After Phase 7 (2026-07-05)**: Friends feature done & wired (commit `b005462`)
   - `flutter analyze` — 0 errors ✅ · `flutter test` — 42/42 pass ✅
   - Pending: test Friends belum ditulis
   - ⚠️ **Env note:** `flutter analyze/test` via fvm meng-upgrade 15 transitive deps
     (analyzer 7.7→8.4, dll) → `pubspec.lock` termodifikasi tapi **sengaja belum
     di-commit**. Perlu keputusan: pin ulang lock lama atau commit upgrade.
   - ⚠️ Butuh Flutter SDK terbaru (`CardTheme` sudah jadi `CardThemeData`)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Git dep resolution for flutter-package-core | Pause and ask user for help if blocked — they will resolve it |
| Platform config rebranding (bundle IDs) | Carefully update build.gradle + Info.plist |
| DI registration order | Follow pattern: core → session → auth → home → health → duel → router |
| Duel real-time stream lifecycle | Cancel subscription in BLoC close() |
| Firebase config | Copy firebase_options.dart, update only bundle IDs |
