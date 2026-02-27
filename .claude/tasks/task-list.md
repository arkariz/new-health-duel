# Health Duel - Task List

**Last Updated:** 2026-02-17

---

## ✅ Phase 1: Documentation (COMPLETED)
All tasks done. See PROGRESS.md for details.

---

## ✅ Phase 2: Project Foundation & Core Port (COMPLETED)
All tasks done. See PROGRESS.md for details.

---

## ✅ Phase 3: Port Features (COMPLETED)
All tasks done. See PROGRESS.md for details.

---

## ✅ Phase 3.5: Architecture Refinement — AuthCredentials (COMPLETED)
Rename User → AuthCredentials. See PROGRESS.md for details.

---

## ✅ Phase 4: Build Duel Feature (COMPLETED)
All tasks done (Domain, Data, Presentation, Routing, DI). See PROGRESS.md for details.

---

## ✅ Phase 4.5: Auth Cleanup & Optimization (COMPLETED)

### Task #A1: Auth Code Quality Review ✅
**Status:** COMPLETED
**Agent:** Explore (reviewer)
**Result:** 82/100 score, found type safety + convention issues

### Task #A2: Apply Auth Fixes ✅
**Status:** COMPLETED
**Agent:** Lead (direct)
**Changes:**
- Remove signOut() from AuthRepository (moved to Session)
- Delete AuthGuard widget
- Fix AuthStateChanged.user: dynamic → UserModel?
- Use AppRoutes constants (remove hardcoded route strings)
- Add deduplication comment to _onAuthStateChanged
- Refactor LoginLoadingView UI
**Commit:** `6aee88a`

### Task #A3: QA Verification ✅
**Status:** COMPLETED
**Result:** 42/42 tests pass, flutter analyze clean

---

## 🔲 Phase 5 (Plan Step 15): Write Duel Tests — NEXT

### Task #15: Write Duel Tests ⏳
**Status:** PENDING
**Agent:** Coder (general-purpose)
**Action:** Write unit tests for Duel domain + BLoC
**Blocked by:** None
**Scope:**
- test/features/duel/domain/ (entity, use case tests)
- test/features/duel/bloc/ (DuelBloc tests)

### Task #16: Duel Code & Architecture Review ⏳
**Status:** PENDING
**Agent:** Reviewer (Explore)
**Blocked by:** Task #15

### Task #17: Duel QA Verification ⏳
**Status:** PENDING
**Agent:** QA (Bash)
**Action:** flutter analyze, flutter test, flutter build apk
**Blocked by:** Task #16
