# Health Duel - Task List

## Phase 2: Project Foundation & Core Port

### Task #1: Extract Core Implementation Details ✅
**Status:** COMPLETED
**Agent:** Analyzer (Explore)
**Output:** 86 Dart files mapped from `reference_project/fintrack_lite/lib/core/`
- EffectBloc pattern (5-part system) fully documented
- DI registration order identified
- Critical rebranding issue found (firebase_options.dart iOS bundle ID)
- All files already use `package:health_duel` imports

### Task #2: Scaffold Project Structure ✅
**Status:** COMPLETED
**Agent:** Coder (Lead direct)
**Completed:**
- Created `health_duel/` directory structure
- Created `lib/core/`, `lib/data/`, `lib/features/` subdirectories
- Created `pubspec.yaml` with git dependencies for flutter-package-core
- Copied platform configs (android/, ios/, web/, env/)
- Copied config files (analysis_options.yaml, .gitignore, .metadata)
- Created placeholder files (main.dart, app.dart)
- Verified Android bundle ID: `com.example.health_duel` ✓

### Task #3: Validate Foundation ⏳
**Status:** PENDING (NEXT)
**Agent:** QA (Bash)
**Action:** Run `flutter pub get` to validate git dependencies resolve correctly
**Blocked by:** None
**Critical:** This validates that git dep for flutter-package-core works before porting code

### Task #4: Port Core Infrastructure ⏳
**Status:** PENDING
**Agent:** Coder (general-purpose)
**Action:** Port 86 core files from reference to health_duel
**Blocked by:** Task #3 (must pass validation first)
**Files to port:**
- lib/core/bloc/ (18 files)
- lib/core/presentation/ (33 files)
- lib/core/config/ (7 files)
- lib/core/di/ (3 files)
- lib/core/error/ (3 files)
- lib/core/router/ (5 files)
- lib/core/theme/ (9 files)
- lib/core/utils/ (6 files)
- lib/core.dart (1 barrel file)
- Total: 86 files

---

**Last Updated:** 2026-02-09 13:30
