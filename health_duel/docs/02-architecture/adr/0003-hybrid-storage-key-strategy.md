# Hybrid Storage Key Strategy

## 1. Metadata
- **Decision ID:** ADR-003
- **Date:** 2026-02-08
- **Roadmap Phase:** Phase 1 (Foundation & Core Infrastructure)
- **Status:** Accepted
- **Scope:** Global (Data Layer & Core Configuration)

## 2. Context (Why this decision exists)

In a Clean Architecture modular app, we need to manage Hive box names and
preference keys (provided by `flutter-package-core`'s storage module). We faced
a conflict between two architectural goals:

1. **Centralization:** Having a single place to see all storage keys to prevent
   collisions and ease auditing
2. **Modularity:** Keeping features self-contained so they can be extracted or
   tested in isolation without depending on a central core registry

**Problem:**
Using a central `StorageKeys` class for *everything* couples all features to
`core`. Using hardcoded strings in features invites collision risks.

**Constraints:**
- Features should be as decoupled as possible (supports future modularization)
- Naming collisions in Hive boxes must be avoided (Hive boxes share a global
  namespace)
- Local storage used for: completed duels cache, user profiles cache, friend
  lists cache, app preferences, auth tokens

## 3. Decision

**We will adopt a Hybrid Storage Key Strategy:**

1. **Shared/Global Keys** (Preferences, Auth Tokens, Encryption Keys) → Defined
   in `lib/core/config/storage_keys.dart`
2. **Feature-Specific Box Names** → Defined as **private constants** inside the
   Feature's `LocalDataSource`
3. **Naming Convention** → Feature box names MUST follow the pattern:
   `healthduel_{feature_name}_{box_type}` to prevent collisions

## 4. Options Considered

**Option A — Centralized Registry (The Monolith Way)**
- All keys defined in `core/config/storage_keys.dart`
- Features import `core`

**Option B — Fully Decentralized**
- No central file
- Features use hardcoded strings

**Option C — Hybrid Strategy (Chosen)**
- Shared keys in core
- Feature keys in feature modules (with naming convention)

## 5. Trade-offs Analysis (Critical Section)

### Option A — Centralized Registry

**(+) Pros:**
- Zero collision risk (compiler checks duplicates)
- Easy to audit all storage usage
- Clear visibility of all storage keys in one place

**(−) Cons:**
- **High Coupling:** Feature A depends on a file that contains keys for Feature B
- **Breaks Modularity:** Extracting a feature requires modifying `core`
- **Merge Conflicts:** Multiple developers editing same file
- **Violates SRP:** Single file responsible for all feature storage

**Long-term Impact:**
Tight coupling prevents feature extraction, makes testing harder, creates
bottleneck for parallel development.

---

### Option B — Fully Decentralized

**(+) Pros:**
- Maximum modularity
- Features completely independent
- No coupling to core configuration

**(−) Cons:**
- **High Collision Risk:** Two features might accidentally use "cache" or
  "settings" box
- **Hard to Audit:** Must search entire codebase to find all box names
- **No Standards:** Each developer might use different naming patterns

**Long-term Impact:**
Potential runtime errors from box name collisions, harder to audit storage
usage, inconsistent naming across features.

---

### Option C — Hybrid Strategy (Chosen)

**(+) Pros:**
- **Feature Isolation:** Features own their data definitions
- **Modularity:** Easy to extract features to packages
- **Zero Coupling:** Core doesn't know about `duel` or `health` boxes
- **Selective Centralization:** Truly shared keys (auth token) remain central
- **Clear Boundaries:** Easy to distinguish global vs feature-specific storage

**(−) Cons:**
- **Manual Collision Prevention:** Relies on strict naming convention
  (`healthduel_*`)
- **Audit Requires Search:** Can't view all storage keys in single file
- **Discipline Required:** Developers must follow naming convention

**Long-term Impact:**
Maintainable, modular architecture with clear feature boundaries. Collision
risk mitigated by naming convention and code review.

---

**Why Option C Wins:**
1. **Modularity Goal:** Aligns with Clean Architecture principle of feature
   independence
2. **Extraction Ready:** Features can be moved to separate packages easily
3. **Testing Benefits:** Feature tests don't depend on global configuration file
4. **Development Velocity:** Developers don't need to touch core for new feature
   storage
5. **Collision Mitigation:** Strict naming convention (`healthduel_*`) prevents
   accidents

## 6. Consequences

### What Becomes Easier

- ✅ **Refactoring:** Moving a feature to a separate package/repo is trivial
- ✅ **Testing:** Feature tests don't depend on global configuration file
- ✅ **Development:** Developers don't need to touch `core` just to add a new
     feature box
- ✅ **Parallel Work:** No merge conflicts on central configuration file
- ✅ **Feature Independence:** Each feature owns its storage completely

### What Becomes Harder

- ❌ **Auditing:** Can't just open one file to see every Hive box used in the app
- ❌ **Collision Check:** Developers must be disciplined about the `healthduel_`
     prefix
- ❌ **Onboarding:** New developers must learn the naming convention

### Accepted Risks

**Risk 1: Accidental Box Name Collisions**
- Two developers might accidentally choose the same box name
- Example: Both using "cache" for different features

**Mitigation:**
- Enforce strict naming convention: `healthduel_{feature}_{type}`
- Code review checklist includes box name verification
- Prefix `healthduel_` makes collision with other apps impossible
- Document naming convention in CONTRIBUTING.md

**Risk 2: Audit Complexity**
- No single source of truth for all storage keys

**Mitigation:**
- Use IDE search to find all `_boxName` constants
- Document known box names in this ADR
- Consider automated test to detect duplicate box names

## 7. Implementation Notes

### Core Configuration (Shared Keys Only)

```dart
// lib/core/config/storage_keys.dart

/// Global storage keys for app-wide configuration and shared data.
///
/// Only truly global/shared keys belong here. Feature-specific box names
/// should be defined as private constants in their respective LocalDataSource
/// implementations.
class StorageKeys {
  StorageKeys._(); // Private constructor prevents instantiation

  // Shared preferences box
  static const String appPreferences = 'healthduel_preferences';

  // Secure storage for sensitive data
  static const String secureKeyStorage = 'healthduel_secure_keys';

  // Authentication
  static const String authToken = 'auth_token';
  static const String authRefreshToken = 'auth_refresh_token';
  static const String userId = 'user_id';

  // App configuration
  static const String appVersion = 'app_version';
  static const String firstLaunch = 'first_launch';
  static const String onboardingCompleted = 'onboarding_completed';

  // Cache timestamps (for TTL checks)
  static const String profileCacheTimestamp = 'profile_cache_timestamp';
  static const String friendsCacheTimestamp = 'friends_cache_timestamp';
}
```

### Feature Implementation (Duel Feature Example)

```dart
// lib/features/duel/data/datasources/duel_local_data_source.dart
import 'package:flutter_package_core/storage.dart';
import '../models/duel_dto.dart';

abstract class DuelLocalDataSource {
  Future<List<DuelDto>> getCompletedDuels(String userId);
  Future<void> cacheCompletedDuels(List<DuelDto> duels);
  Future<void> clearCache();
}

class DuelLocalDataSourceImpl implements DuelLocalDataSource {
  final Database _database;

  // Private constant, internal to this feature
  // Naming convention: healthduel_{feature}_{box_type}
  static const String _boxName = 'healthduel_duels_completed_v1';

  DuelLocalDataSourceImpl(this._database);

  static Future<DuelLocalDataSourceImpl> create() async {
    final database = await Database.init<DuelDto>(
      name: _boxName,
      fromJson: (json) => DuelDto.fromJson(json),
    );
    return DuelLocalDataSourceImpl(database);
  }

  @override
  Future<List<DuelDto>> getCompletedDuels(String userId) async {
    final allDuels = await _database.getAll();
    return allDuels
        .where((duel) =>
            duel.challengerId == userId || duel.challengedId == userId)
        .toList();
  }

  @override
  Future<void> cacheCompletedDuels(List<DuelDto> duels) async {
    for (final duel in duels) {
      await _database.put(duel.id, duel);
    }
  }

  @override
  Future<void> clearCache() async {
    await _database.clear();
  }
}
```

### Profile Feature Example

```dart
// lib/features/profile/data/datasources/profile_local_data_source.dart
import 'package:flutter_package_core/storage.dart';
import '../models/user_profile_dto.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileDto?> getProfile(String userId);
  Future<void> cacheProfile(UserProfileDto profile);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Database _database;

  // Feature-specific box name
  static const String _boxName = 'healthduel_profiles_cache_v1';

  ProfileLocalDataSourceImpl(this._database);

  static Future<ProfileLocalDataSourceImpl> create() async {
    final database = await Database.init<UserProfileDto>(
      name: _boxName,
      fromJson: (json) => UserProfileDto.fromJson(json),
    );
    return ProfileLocalDataSourceImpl(database);
  }

  @override
  Future<UserProfileDto?> getProfile(String userId) async {
    return await _database.get(userId);
  }

  @override
  Future<void> cacheProfile(UserProfileDto profile) async {
    await _database.put(profile.id, profile);
  }

  @override
  Future<void> clearCache() async {
    await _database.clear();
  }
}
```

### Friend Feature Example

```dart
// lib/features/friend/data/datasources/friend_local_data_source.dart
class FriendLocalDataSourceImpl implements FriendLocalDataSource {
  final Database _database;

  static const String _boxName = 'healthduel_friends_cache_v1';

  // ... implementation similar to above
}
```

### Naming Convention Rules

**Format:** `healthduel_{feature}_{box_type}_{version}`

**Components:**
1. **Prefix:** Always `healthduel_` (prevents collision with other apps)
2. **Feature:** Feature name (e.g., `duels`, `profiles`, `friends`, `health`)
3. **Box Type:** Purpose of box (e.g., `cache`, `completed`, `settings`)
4. **Version:** Optional version suffix (e.g., `v1`, `v2`) for schema migrations

**Examples:**
- ✅ `healthduel_duels_completed_v1` - Completed duels cache
- ✅ `healthduel_profiles_cache_v1` - User profiles cache
- ✅ `healthduel_friends_cache_v1` - Friend list cache
- ✅ `healthduel_health_data_v1` - Health data cache
- ❌ `cache` - Too generic, collision risk
- ❌ `duel_cache` - Missing prefix, collision risk with other apps
- ❌ `healthDuelCache` - Inconsistent naming (use snake_case)

### Known Box Names (Living Documentation)

This list is maintained for audit purposes:

**Global (Core):**
- `healthduel_preferences` - App preferences
- `healthduel_secure_keys` - Encrypted sensitive data

**Feature-Specific:**
- `healthduel_duels_completed_v1` - Completed duels (immutable cache)
- `healthduel_profiles_cache_v1` - User profiles (15-minute TTL)
- `healthduel_friends_cache_v1` - Friend lists (24-hour TTL)
- `healthduel_health_data_v1` - Health data cache (if needed)
- `healthduel_notifications_v1` - Notification history (if needed)

**Future Additions:**
Add new box names here when features are implemented.

### Version Migration Strategy

When schema changes require a new box version:

```dart
class DuelLocalDataSourceImpl {
  static const String _boxName = 'healthduel_duels_completed_v2'; // Incremented
  static const String _oldBoxName = 'healthduel_duels_completed_v1';

  static Future<DuelLocalDataSourceImpl> create() async {
    // Check if old box exists
    final oldBox = await _checkOldBoxExists(_oldBoxName);
    if (oldBox) {
      await _migrateData(_oldBoxName, _boxName);
      await _deleteOldBox(_oldBoxName);
    }

    final database = await Database.init<DuelDto>(
      name: _boxName,
      fromJson: (json) => DuelDto.fromJson(json),
    );
    return DuelLocalDataSourceImpl(database);
  }

  // Migration logic...
}
```

### Anti-patterns to Avoid

❌ **DO NOT:**
- Use generic names without prefix: `cache`, `settings`, `data`
- Define feature box names in core/config/storage_keys.dart
- Hardcode box names in multiple places within a feature
- Use camelCase for box names (use snake_case)
- Skip versioning suffix if schema might change

✅ **DO:**
- Always use `healthduel_` prefix for all box names
- Define box name as private constant in LocalDataSource
- Use descriptive box type: `completed`, `cache`, `pending`
- Include version suffix for future-proofing: `_v1`
- Document new box names in this ADR when adding features

## 8. Revisit Criteria

This decision should be re-evaluated if:

### Quantitative Triggers

1. **Collision Incidents:** Actual box name collision occurs in production
2. **Feature Count:** Number of features exceeds 20 (audit becomes very difficult)
3. **Storage Audit Requests:** Product/compliance requires comprehensive storage
   audit (> 2 requests)

### Qualitative Triggers

4. **Modularization:** App is split into multiple micro-apps (might need shared
   schema registry)
5. **Database Migration:** Move from Hive to SQLite/Drift where schema management
   is inherently centralized
6. **Team Feedback:** Multiple developers struggle with naming convention or
   collision prevention
7. **Security Audit:** Security review requires centralized storage key registry

### Phase Gates

- **Phase 2 Retrospective:** Evaluate if naming convention prevented collisions
- **Phase 3 Launch:** Assess audit requirements for production release
- **Feature Extraction:** If features are actually extracted to packages, validate
  modularity benefits

## 9. Related Artifacts

### Documentation
- [Architecture Overview](../ARCHITECTURE_OVERVIEW.md) - Data layer architecture
- [Contributing Guidelines](../../CONTRIBUTING.md) - Coding standards and naming
  conventions

### Code References
- `lib/core/config/storage_keys.dart` - Global storage keys
- `flutter-package-core/storage` - Hive database wrapper (git dependency)
- Feature LocalDataSource implementations - Feature-specific box names

### Related ADRs
- [ADR-001: Selective Caching Strategy](0001-selective-caching-strategy.md) -
  Defines what data is cached
- [ADR-007: Git Dependency Strategy](0007-git-dependency-strategy.md) - How
  flutter-package-core is accessed

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead, Coder-Docs
**Approved Date:** 2026-02-08
**Implementation Status:** Accepted for Phase 1, pattern established from reference
project
