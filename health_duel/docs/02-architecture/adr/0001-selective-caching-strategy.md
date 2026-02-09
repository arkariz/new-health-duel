# Selective Caching Strategy for Health Duel

## 1. Metadata
- **Decision ID:** ADR-001
- **Date:** 2026-02-08
- **Roadmap Phase:** Phase 1 (Foundation & Core Architecture)
- **Status:** Accepted
- **Scope:** Global (affects all data access patterns)

## 2. Context (Why this decision exists)

Health Duel is a social health competition application where **real-time duel
progress is critical**. During architectural planning, we needed to decide how
to handle data caching and offline support.

**Problem:**
- Duel data (step counts, lead status, timers) must be accurate and near real-time
- Some data (user profiles, friend lists) changes infrequently and can benefit
  from caching
- Network failures should gracefully degrade UX where appropriate
- Health data sync already has delays from platform APIs (HealthKit/Health Connect)
- Complexity of sync queues and conflict resolution must be minimized for MVP

**Constraints:**
- **Timeline:** Phase 1 focus is on core architecture, not advanced offline features
- **Team:** Small team focused on Clean Architecture learning and MVP delivery
- **Requirements:** Duel data accuracy and fairness > Offline capability
- **Roadmap:** Real-time competition features require current data
- **Health APIs:** Platform health data already introduces sync delays (we can't
  control)

## 3. Decision

**We will implement a selective caching strategy:**

- **NO CACHE** for real-time competitive data (active duels, step counts,
  lead status)
- **SHORT-TERM CACHE (15 minutes)** for semi-static user data (profiles, avatars)
- **MEDIUM-TERM CACHE (24 hours)** for static reference data (friend lists)
- **PERSISTENT STORAGE** for app configuration, preferences, and authentication
  tokens
- **COMPLETED DUELS** cached indefinitely (historical data, immutable)

All active duel operations will fetch directly from Firestore with real-time
listeners. User profiles use cache-first with short TTL. Historical data is
cached permanently after completion.

## 4. Options Considered

**Option A — Offline-First for All Data**
- Cache all data locally with sync queue
- Implement conflict resolution
- Support full offline operation

**Option B — Remote-Only (No Cache)**
- All data fetched from Firestore on every request
- No caching whatsoever
- Simple but poor UX and high Firestore costs

**Option C — Selective Caching (Chosen)**
- Active duels: Real-time listeners (Firestore snapshots)
- Completed duels: Cached permanently
- User data: Short TTL cache (15 min)
- Balance between accuracy, UX, and cost

## 5. Trade-offs Analysis (Critical Section)

### Option A — Offline-First for All Data

**(+) Pros:**
- Full offline capability
- Better UX for connectivity issues
- Optimistic UI updates

**(−) Cons:**
- Complex sync queue implementation
- Conflict resolution for step counts (which source of truth?)
- Risk of unfair competition if stale data shown
- Multi-device sync challenges for duel state
- **Fairness Issue:** Users could see different lead status = unfair competition

**Long-term Impact:**
High maintenance burden, potential fairness issues in competitive features,
complex debugging of sync conflicts.

---

### Option B — Remote-Only

**(+) Pros:**
- Always fresh data
- Zero sync complexity
- Simple implementation
- Fair competition (everyone sees same data)

**(−) Cons:**
- Poor UX without internet
- Repeated Firestore reads = high costs
- Slow perceived performance
- Can't view duel history offline

**Long-term Impact:**
Simple but poor user experience, high Firebase costs at scale, no offline
viewing of past duels.

---

### Option C — Selective Caching (Chosen)

**(+) Pros:**
- Active duel data always accurate and fair
- Real-time updates via Firestore listeners
- User profiles load instantly from cache
- Completed duels viewable offline
- Firestore costs optimized (cache static data)
- Clear architectural boundaries

**(−) Cons:**
- Network required for active duel participation
- No offline duel creation or acceptance
- Real-time listeners consume connections

**Long-term Impact:**
Maintainable, fair competition, good UX for common cases, controlled Firebase
costs.

**Why Option C Wins:**
1. **Fairness First:** Competition requires real-time accuracy for all participants
2. **Complexity Minimized:** No sync queue = simpler implementation and fewer bugs
3. **Performance Optimized:** Cached profiles and history improve perceived speed
4. **Cost Controlled:** Avoid unnecessary Firestore reads while maintaining
   real-time for critical data
5. **Clear Boundaries:** Easy to reason about what's cached and what's real-time

## 6. Consequences

### What Becomes Easier

- ✅ **Fairness:** All users see identical duel state (no advantage from stale data)
- ✅ **Testing:** No need to test sync conflict scenarios
- ✅ **Reasoning:** Clear rules about data freshness
- ✅ **Correctness:** Duel progress always accurate
- ✅ **Performance:** Static data loads instantly from cache
- ✅ **Cost Control:** Firestore reads minimized for cacheable data

### What Becomes Harder

- ❌ **Offline Duels:** Users cannot create/accept duels without internet
- ❌ **Poor Connectivity UX:** Active duel operations fail without network
- ❌ **Connection Management:** Real-time listeners require active connections

### Accepted Risks

**Risk 1: Network Dependency for Core Features**
- Users in low-connectivity areas cannot participate in active duels
- Network latency impacts duel creation and acceptance

**Mitigation:**
- Show clear error messages when network unavailable
- Implement retry logic with exponential backoff for transient issues
- Cache completed duel history for offline viewing
- Display last-known step count with sync timestamp

**Risk 2: Firestore Connection Limits**
- Real-time listeners consume connections (limit: 1 million concurrent per project)
- Cost: Listener connections billed

**Mitigation:**
- Monitor concurrent listener count
- Close listeners when app backgrounded
- Re-establish listeners on app resume
- Listeners only for active duels (auto-close on completion)

**Risk 3: Stale Profile Data**
- 15-minute cache may show outdated avatar or name

**Mitigation:**
- Acceptable trade-off (profile changes are rare)
- Manual refresh option in UI
- Force refresh on profile edit

## 7. Implementation Notes

### Repository Pattern Implementation

**Active Duel Repository (REAL-TIME, NO CACHE):**
```dart
class DuelRepositoryImpl implements DuelRepository {
  final DuelRemoteDataSource _remoteDataSource;
  // NO localDataSource for active duels!

  @override
  Future<Either<Failure, Duel>> getDuelById(String id) async {
    try {
      final model = await _remoteDataSource.getDuel(id);
      return Right(model.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    }
  }

  @override
  Stream<Duel> watchDuel(String id) {
    // Real-time Firestore listener
    return _remoteDataSource
        .watchDuel(id)
        .map((dto) => dto.toEntity());
  }

  @override
  Future<Either<Failure, List<Duel>>> getCompletedDuels(String userId) async {
    try {
      // Check local cache first for completed duels
      final cached = await _localDataSource.getCompletedDuels(userId);
      if (cached.isNotEmpty) {
        return Right(cached.map((dto) => dto.toEntity()).toList());
      }

      // Fetch from remote and cache
      final remote = await _remoteDataSource.getCompletedDuels(userId);
      await _localDataSource.cacheCompletedDuels(remote);
      return Right(remote.map((dto) => dto.toEntity()).toList());
    } on CoreException catch (e) {
      // Fallback to cache on network error
      if (e is NoInternetConnectionException) {
        final cached = await _localDataSource.getCompletedDuels(userId);
        if (cached.isNotEmpty) {
          return Right(cached.map((dto) => dto.toEntity()).toList());
        }
      }
      return Left(ExceptionMapper.toFailure(e));
    }
  }
}
```

**User Profile Repository (WITH SHORT CACHE):**
```dart
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;
  final Preference _preference;

  static const _cacheKey = 'profile_cache';
  static const _cacheTimestampKey = 'profile_timestamp';
  static const _cacheDuration = Duration(minutes: 15);

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      // Check cache TTL
      final timestamp = _preference.box.get(_cacheTimestampKey);
      if (_isCacheFresh(timestamp, _cacheDuration)) {
        final cached = await _localDataSource.getProfile(userId);
        return Right(cached.toEntity());
      }

      // Fetch from Firestore
      final remote = await _remoteDataSource.getProfile(userId);

      // Update cache
      await _localDataSource.cacheProfile(remote);
      await _preference.box.put(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      return Right(remote.toEntity());
    } on CoreException catch (e) {
      // Fallback to stale cache on network error
      if (e is NoInternetConnectionException) {
        final cached = await _localDataSource.getProfile(userId);
        return Right(cached.toEntity());
      }
      return Left(ExceptionMapper.toFailure(e));
    }
  }

  bool _isCacheFresh(String? timestamp, Duration ttl) {
    if (timestamp == null) return false;
    final cacheTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cacheTime) < ttl;
  }
}
```

**Friend List Repository (WITH 24H CACHE):**
```dart
class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource _remoteDataSource;
  final FriendLocalDataSource _localDataSource;
  final Preference _preference;

  static const _cacheDuration = Duration(hours: 24);

  @override
  Future<Either<Failure, List<User>>> getFriends(String userId) async {
    try {
      final timestamp = _preference.box.get('friends_timestamp');
      if (_isCacheFresh(timestamp, _cacheDuration)) {
        final cached = await _localDataSource.getFriends(userId);
        return Right(cached.map((dto) => dto.toEntity()).toList());
      }

      final remote = await _remoteDataSource.getFriends(userId);
      await _localDataSource.cacheFriends(remote);
      await _preference.box.put(
        'friends_timestamp',
        DateTime.now().toIso8601String(),
      );

      return Right(remote.map((dto) => dto.toEntity()).toList());
    } on CoreException catch (e) {
      if (e is NoInternetConnectionException) {
        final cached = await _localDataSource.getFriends(userId);
        return Right(cached.map((dto) => dto.toEntity()).toList());
      }
      return Left(ExceptionMapper.toFailure(e));
    }
  }
}
```

### Feature Classification Table

| Feature | Data Type | Caching Strategy | TTL | Offline Support | Rationale |
|---------|-----------|------------------|-----|-----------------|-----------|
| Active Duels | Real-time Competitive | Real-time listeners, no cache | N/A | No | Fairness requires live data |
| Step Counts | Real-time Competitive | Firestore sync, no cache | N/A | No | Health API already delayed |
| Lead Status | Real-time Competitive | Real-time listeners | N/A | No | Competition integrity |
| Completed Duels | Historical Immutable | Permanent cache | ∞ | Yes | Data never changes |
| User Profiles | Semi-static | Cache-first | 15 min | Stale OK | Rare changes |
| Friend Lists | Semi-static | Cache-first | 24 hours | Stale OK | Infrequent updates |
| Avatars | Semi-static | Cache-first | 24 hours | Stale OK | Rarely change |
| Auth Tokens | Config | Persistent | Until logout | Yes | Local-only |
| App Settings | Config | Persistent | Until changed | Yes | Local-only |

### Cache Invalidation Rules

**Manual Invalidation (User-Triggered):**
- Profile cache cleared on profile edit
- Friend cache cleared on friend add/remove
- Pull-to-refresh on list screens clears cache

**Automatic Invalidation:**
- Duel completion triggers cache of completed duel
- Logout clears all user-specific caches
- App upgrade clears all caches (version migration)

**Staleness Handling:**
- Display "Last updated: X minutes ago" for cached data
- "Refresh" button on profile/friend screens
- Background refresh when app returns to foreground

### Anti-patterns to Avoid

❌ **DO NOT:**
- Cache active duel step counts (fairness violation)
- Show stale lead status to users (unfair advantage)
- Implement optimistic updates for duel acceptance (race conditions)
- Cache health permission status (may change in device settings)

✅ **DO:**
- Use real-time Firestore listeners for all active duel data
- Cache completed duels permanently (immutable historical data)
- Show clear sync timestamps for cached data
- Implement graceful degradation with stale cache fallback

## 8. Revisit Criteria

This decision should be re-evaluated if:

### Quantitative Triggers

1. **User Feedback:** > 30% of users report connectivity issues preventing duel
   participation
2. **Firestore Costs:** Real-time listener costs exceed budget thresholds
3. **Connection Limits:** Approaching Firestore concurrent connection limits
   (> 80% of 1M)
4. **Offline Requests:** > 20% of users request offline duel creation feature

### Qualitative Triggers

5. **Requirements Change:** Offline duel creation becomes a core product requirement
6. **Roadmap Phase:** Entering Phase 3 where offline-first is prioritized
7. **Technical Evolution:** Industry-standard offline-sync libraries mature and
   integrate well with Firestore
8. **Competition Fairness:** Evidence that real-time listeners introduce
   unfairness (e.g., iOS vs Android sync delays)

### Phase Gates

- **Phase 1 Retrospective:** Evaluate cache hit rates and Firestore costs
- **Phase 2 Launch:** Analyze actual user connectivity patterns and offline
  feature requests
- **6-Month Review:** Assess Firebase bill and user complaints about network
  dependency

## 9. Related Artifacts

### Documentation
- [Architecture Overview](../ARCHITECTURE_OVERVIEW.md) - Data flow patterns
- [Product Requirements](../../01-product/prd-health-duels-1.0.md) - Real-time
  requirements

### Code References
- `packages/storage/` - Hive-based caching infrastructure (from flutter-package-core)
- `packages/exception/` - Error handling for network failures
- `packages/firestore/` - Firestore wrapper with real-time listener support

### Related ADRs
- [ADR-002: Exception Isolation Strategy](0002-exception-isolation-strategy.md)
- [ADR-007: Git Dependency Strategy](0007-git-dependency-strategy.md)

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead, Coder-Docs
**Approved Date:** 2026-02-08
**Implementation Status:** Accepted for Phase 1
