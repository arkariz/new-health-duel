# Next Session Plan

## Status Recap
- ✅ Phase 1: Documentation (COMPLETED)
- ✅ Phase 2: Project Foundation & Core Port (COMPLETED & APPROVED)
- ✅ Phase 3: Port Features (COMPLETED - Auth, Home, Health)
- ✅ Phase 3.5: Architecture Refinement (COMPLETED)
  - Write vs Read Model discussion: DONE
  - ADR-008 created: AuthCredentials pattern documented
  - Refactoring completed: User → AuthCredentials
  - All tests passing: 42/42 ✅
  - Build successful ✅

## Next: Phase 4 - Build Duel Feature

**Ready to start!** Phase 4 will build the core Duel feature from scratch.

### What Happens in Phase 4:
1. **Planner Agent** will design the Duel feature architecture at runtime
   - Domain models (Duel entity, DuelInvite, DuelParticipant)
   - Use cases (CreateDuel, JoinDuel, UpdateSteps, CompleteDuel)
   - Repository contracts
   - BLoC structure
   - UI/UX flow

2. **Coder Agents** will implement based on Planner's design
   - Domain layer (entities, use cases, repositories)
   - Data layer (models, data sources, repository implementations)
   - Presentation layer (BLoCs, pages, widgets)

3. **Reviewer & QA** will validate the implementation
   - Architecture review
   - Tests (unit + widget)
   - Static analysis
   - Build verification

### Key Architectural Decisions Already Made:
- ✅ EffectBloc pattern for state management
- ✅ Value Objects for domain validation
- ✅ Write/Read model separation (Command/Query)
- ✅ Clean Architecture layers
- ✅ GetIt DI + GoRouter navigation
- ✅ Firebase Auth + Firestore backend

### Current Work: Phase 4 Domain Layer

**Design:** ✅ COMPLETED (saved to `.claude/designs/phase-4-duel-architecture.md`)
**Next:** Implement domain layer (~15 files)

### Files to Create:
1. Value Objects (5):
   - duel_id.dart
   - user_id.dart
   - step_count.dart
   - duel_status.dart
   - duel_result.dart

2. Entity (1):
   - duel.dart (rich domain model)

3. Repository (1):
   - duel_repository.dart (interface)

4. Use Cases (9):
   - create_duel.dart
   - accept_duel.dart
   - decline_duel.dart
   - update_step_count.dart
   - get_active_duels.dart
   - get_pending_duels.dart
   - get_duel_history.dart
   - watch_duel.dart
   - sync_health_data.dart

## Resume Command
Say: **"lanjut implement domain"** atau **"continue"**

### Current Codebase Stats
- **Total Files:** 164 Dart files
- **Tests:** 42/42 passing
- **Build:** Compiles successfully
- **Architecture:** 100% compliant
- **Documentation:** 11 docs + 8 ADRs

### Token Status (This Session)
- Used: ~73k / 200k (36.5%)
- Remaining: ~127k tokens
- Safe to continue or start Phase 4
