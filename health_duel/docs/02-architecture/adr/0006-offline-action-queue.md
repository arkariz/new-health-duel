# Offline Action Queue + Conflict Resolution

## 1. Metadata
- **Decision ID:** ADR-006
- **Date:** 2026-07-17
- **Roadmap Phase:** Phase 5 (UI Redesign) / cross-cutting reliability work
- **Status:** Accepted
- **Scope:** Global (core module) + Feature: Duel (executors)

## 2. Context (Why this decision exists)

PRD §8.2 **NFR-REL-001 "Offline Support"** requires "Queue actions for sync
when connectivity returns." That checkbox has been unchecked since MVP scope
was defined, because [ADR-001: Selective Caching Strategy](0001-selective-caching-strategy.md)
explicitly rejected offline queues for MVP (Option A was rejected in favor of
Option C — real-time listeners, no sync queue) on fairness and complexity
grounds.

**This ADR is a controlled deviation from ADR-001**, scoped narrowly to
*write actions the user initiates while offline* (accept/decline/cancel a
duel, create a duel, and periodic step sync) — not to caching or offline
viewing of real-time duel state. ADR-001's core fairness argument (no cached
lead status, no optimistic UI mutation of duel state) is preserved: a duel
stays in its last-known state until the queued action is confirmed by
Firestore.

**What changed since ADR-001:**
- The app now has real infrastructure ADR-001 didn't have: `ConnectivityCubit`
  (app-wide, DI-registered), Hive encrypted storage via the `storage` git
  package, and idempotent Firestore transactions in `CompleteDuel`/
  `ExpirePendingDuel` that already demonstrate safe replay-style writes.
- User feedback identified "action silently does nothing while offline" as a
  worse experience than "action queues and syncs automatically," specifically
  for accept/decline/create — actions that are infrequent, discrete, and
  don't require real-time fairness guarantees the way step counts or lead
  status do.

**Key implementation-blocking findings from code exploration:**
- `DuelRepositoryImpl` maps every exception to `ServerFailure` — it never
  surfaces `NetworkFailure` — and Firestore *buffers* writes made while
  offline (the write `Future` hangs rather than failing). This means offline
  detection **must be proactive** (check `ConnectivityCubit.isOffline` in the
  bloc *before* calling the use case), not reactive (catching a failure that
  will never come).
- `UiEffect` already differentiates instances by timestamp, so repeat
  `ShowSnackBarEffect`s are not silently deduped by `EffectListener` — but the
  established codebase convention is still to `clearEffect()` before setting
  a new one on a long-lived global cubit, so this ADR follows that pattern for
  consistency.
- `ConnectivityCubit` starts in `unknown` and calls `init()` unawaited; the
  processor must subscribe to the connectivity stream *before* checking
  `isOnline()` for the initial drain, or it can race the cubit's first status
  emission.

## 3. Decision

We will add a **generic, feature-agnostic offline action queue** at
`lib/core/offline_queue/`, with an **executor registry** that features (only
`duel` for now) register against at DI time — mirroring the
[ADR-004](0004-registry-based-ui-effect-flow-architecture.md) registry
pattern already used for `UiEffect` handling.

**Locked decisions:**
1. **Scope:** all duel write actions — `AcceptDuel`, `DeclineDuel`/cancel,
   `CreateDuel`, and step sync (`SyncHealthData`).
2. **Conflict handling:** if replaying a queued action fails domain
   validation (e.g. the duel expired or changed while offline), **drop the
   action and notify the user** via `ShowSnackBarEffect`. Firestore remains
   the single source of truth — we do not attempt automatic merge/retry for
   validation failures.
3. **Persistence & draining:** actions persist in Hive (encrypted, via the
   `storage` package), retried with exponential backoff, and drained when
   `ConnectivityCubit` transitions to online.
4. **No optimistic UI mutation:** a duel queued for accept/decline stays
   rendered in its pre-action state until the queued action is confirmed —
   this preserves ADR-001's fairness guarantee that nobody sees a duel state
   that hasn't actually happened in Firestore yet.
5. **Replay reuses existing use cases** (`AcceptDuel`, `DeclineDuel`,
   `CreateDuel`, `SyncHealthData`) rather than re-implementing Firestore
   calls — so domain validation re-runs on replay, and a `ValidationFailure`
   on replay *is* how a conflict gets detected.

## 4. Options Considered

- **Option A — Repository decorator** (wrap `DuelRepositoryImpl` in an
  offline-queuing decorator that intercepts writes transparently)
- **Option B — Rely on Firestore's built-in offline write buffering**
  (do nothing; let Firestore's SDK queue writes internally)
- **Option C — Explicit queue + executor registry, replay via existing use
  cases** (chosen)

## 5. Trade-offs Analysis

### Option A — Repository decorator
**(+)** Transparent to callers; no bloc changes needed.
**(−)** `DuelRepositoryImpl` maps every exception to `ServerFailure` — a
decorator can't distinguish "genuinely offline" from "Firestore is slow" at
the repository boundary, so it can't reliably decide when to queue vs. fail
fast. Would require rewriting exception mapping first.
**(−)** Firestore already buffers offline writes as hanging Futures — a
decorator sitting below that buffering never even sees a rejected call to
intercept.

### Option B — Firestore's built-in offline buffering
**(+)** Zero implementation cost.
**(−)** No user feedback (write appears to just hang), no retry policy
control, no conflict detection (Firestore's last-write-wins would silently
accept a stale accept/decline against a duel that changed state), no way to
drop-and-notify per this ADR's decision #2.

### Option C — Explicit queue + executor registry (Chosen)
**(+)** Proactive offline detection at the bloc layer sidesteps the
`ServerFailure`-only mapping problem entirely — we check connectivity before
ever calling the repository.
**(+)** Replay through existing use cases means domain validation
(`ValidationFailure`) doubles as conflict detection for free — no separate
conflict-detection logic needed.
**(+)** Executor registry mirrors the already-accepted ADR-004 pattern, so
the codebase gains one consistent "registry of things a bloc/feature plugs
into core" idiom instead of two different ones.
**(−)** More moving parts (queue, processor, executor registry, global
cubit) than a decorator — accepted as necessary given Option A/B's
correctness gaps above.

**Why Option C wins:** it's the only option that gives correct, testable
conflict detection (via existing domain validation) and correct proactive
offline detection (given the `ServerFailure`-only mapping constraint) without
first requiring an unrelated exception-mapping rewrite.

## 6. Consequences

### What Becomes Easier
- Users see immediate feedback ("action queued") instead of a hung UI when
  offline.
- Adding a new offline-queueable action = write one `OfflineActionExecutor`
  and register it — no processor changes needed.
- Conflict detection is "free" (reuses existing use case validation).

### What Becomes Harder
- One more piece of app-wide state (`OfflineQueueCubit`) whose effects must
  not collide with feature-level effects on the same screen.
- "WiFi connected but no real internet" still isn't detected by
  `connectivity_plus` — see Risk 1 below.

### Accepted Risks
**Risk 1 — False positive "online" (WiFi connected, no internet):**
`connectivity_plus` reports link-layer connectivity, not internet reachability.
A queued action can still hang against a network that reports "connected" but
has no route to Firestore. **Mitigation:** the processor wraps every executor
call in `.timeout(20s)` and treats timeouts as retryable (not conflicts), so a
hung write degrades to a retry with backoff rather than blocking the queue
indefinitely. This is a pre-existing gap (same failure mode existed
un-mitigated before this ADR) — fixing it fully (e.g. active reachability
probing) is out of scope here.

**Risk 2 — `ServerFailure` blanket mapping:** since `DuelRepositoryImpl` never
produces `NetworkFailure`, a genuine mid-replay network drop looks identical
to a genuine server error to the processor — both are treated as
retryable-until-`maxAttempts`, then dropped. This is conservative (favors
retrying too much over dropping a valid action too early) but means a
persistently broken server-side write silently exhausts retries and drops
after ~6 attempts rather than surfacing distinctly. **Follow-up (optional,
not in this ADR's scope):** map `FirebaseException.code == 'unavailable'` to
`NetworkFailure` in `ExceptionMapper` so the two cases can be told apart.

**Risk 3 — Strict DI ordering:** `registerOfflineQueueModule()` must run
after `registerCoreModule()` + `getIt.allReady()` (needs `HiveAesCipher`) and
before `registerDuelModule()` (which registers duel executors against the
processor). Documented in `injection.dart`; a future feature adding its own
executors must follow the same ordering.

## 7. Implementation Notes

### Boundaries to maintain
- The global `OfflineQueueCubit` may only emit `ShowSnackBarEffect` —
  **never** a navigation effect. `GoRouter` scope inside `MaterialApp.router`
  is below the app-root `builder`, where the cubit's `EffectListener` lives,
  so a navigation effect there would have no valid `context.go`/`push`
  target.
- `lib/core/offline_queue/` must not import anything from
  `lib/features/**` — it is generic infrastructure. Feature-specific wiring
  (executors, payload shapes) lives in
  `lib/features/duel/domain/offline_executors/`.
- Replay always goes through the existing use case (`AcceptDuel`, etc.), never
  a direct repository/Firestore call — this is what makes conflict detection
  free and keeps validation logic in one place.

### Anti-patterns to avoid
- ❌ Do not optimistically mutate `DuelListLoaded`/`CreateDuelState` when
  queuing an action — the duel must stay in its pre-action state until the
  queued action is confirmed (see decision #4).
- ❌ Do not catch `ServerFailure` in the processor and treat it as a
  conflict — only `ValidationFailure` (from use case domain checks) is a
  conflict signal. Every other failure type is retryable-until-`maxAttempts`.
- ❌ Do not call `context.isOffline` reactively after a use case call fails —
  check `ConnectivityCubit` proactively before calling the use case (see Risk
  section above for why reactive detection doesn't work here).

### File references
- `lib/core/offline_queue/` — queue domain/data/application/presentation/DI
- `lib/features/duel/domain/offline_executors/duel_offline_executors.dart` —
  the four executors
- `lib/core/presentation/widgets/connectivity/` — `ConnectivityCubit`
  (pre-existing, reused as-is)

## 8. Revisit Criteria

- If a second feature (beyond duel) needs offline queuing, revisit whether
  the executor registry needs a more general payload-versioning story.
- If Risk 1 (false-positive online) causes measurable user complaints,
  revisit adding active reachability probing instead of relying on
  `connectivity_plus` alone.
- If the `ServerFailure`-only exception mapping is ever reworked (see Risk 2
  follow-up), revisit whether the processor's retry-vs-drop logic can be made
  more precise.

## 9. Related Artifacts

### Documentation
- [ADR-001: Selective Caching Strategy](0001-selective-caching-strategy.md) —
  amended by this ADR (status updated, see below)
- [ADR-002: Exception Isolation Strategy](0002-exception-isolation-strategy.md) —
  `ExceptionMapper`/`CoreException` pattern reused for the queue's data layer
- [ADR-004: Registry-based UiEffect & Flow-based State Machine](0004-registry-based-ui-effect-flow-architecture.md) —
  executor registry pattern is a direct analogue
- [Product Requirements — NFR-REL-001](../../01-product/prd-health-duels-1.0.md)

### Code References
- `packages/storage/` — Hive-based encrypted storage (`Database<T>`,
  `getHiveAesCipher()`)
- `packages/exception/` — `processBox`/`openBox` exception wrapping, reused
  for the queue's local data source

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead
**Approved Date:** 2026-07-17
**Implementation Status:** Accepted, implementation in progress
