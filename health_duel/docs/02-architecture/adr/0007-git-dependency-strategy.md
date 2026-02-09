# ADR-007: Git Dependency Strategy for Flutter Package Core

## 1. Metadata
- **Decision ID:** ADR-007
- **Date:** 2026-02-08
- **Roadmap Phase:** Phase 1 (Foundation & Documentation)
- **Status:** Accepted
- **Scope:** Global - Core Infrastructure

## 2. Context (Why this decision exists)

Health Duel requires access to a custom Flutter package monorepo (`flutter-package-core`)
that provides core utilities including exception handling, network layer, storage,
security, and Firestore wrappers. This package was originally developed as a
local monorepo dependency in the reference project (`fintrack_lite`).

**Problem:**
The reference project used a local path dependency to the monorepo:
```yaml
dependencies:
  flutter_package_core:
    path: ../../flutter-package-core
```

This approach creates several challenges for the Health Duel project:
1. **Portability:** Local paths are machine-specific and break when the codebase
   is cloned to different environments
2. **Version Control:** The monorepo must be manually synchronized alongside
   the main project
3. **Collaboration:** Team members must maintain identical directory structures
4. **CI/CD:** Build pipelines require complex setup to manage multiple repositories
5. **Onboarding:** New developers must clone and configure multiple repositories
   in specific locations

**Constraints:**
- The `flutter-package-core` repository is hosted on GitHub at
  `https://github.com/arkariz/flutter-package-core`
- The package is not published to pub.dev and should remain private/internal
- Health Duel must use the latest stable version of the core packages
- Team members may have varying levels of Git expertise
- CI/CD pipelines must resolve dependencies automatically

**Current Phase:**
Phase 1 focuses on establishing a solid foundation with proper dependency
management before implementing features.

## 3. Decision

**We will use a git dependency instead of a local path dependency for
`flutter-package-core`.**

The `pubspec.yaml` will specify the dependency as:
```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: main  # or specific tag/commit for version pinning
```

This approach makes the dependency portable, version-controlled, and
automatically resolvable by Flutter's package manager.

## 4. Options Considered

### Option A — Git Dependency (CHOSEN)
Use Flutter's built-in git dependency support to reference the GitHub repository.

### Option B — Local Path Dependency (Reference Project Approach)
Maintain the local path approach from the reference project.

### Option C — Pub.dev Publication
Publish `flutter-package-core` to pub.dev as a public or private package.

### Option D — Git Submodules
Use Git submodules to include the core package repository within the main
repository.

## 5. Trade-offs Analysis

### Option A — Git Dependency (CHOSEN)

**Pros:**
- (+) **Portability:** Works on any machine without manual setup
- (+) **Version Control:** Specific commits/tags can be pinned for stability
- (+) **Automatic Resolution:** `flutter pub get` handles everything
- (+) **CI/CD Friendly:** No additional configuration needed
- (+) **Simple Onboarding:** Clone one repo, run `flutter pub get`, done
- (+) **Native Flutter Support:** Built-in feature, no external tools required
- (+) **Branch Flexibility:** Can reference `main`, tags, or specific commits
- (+) **Authentication:** Supports HTTPS (tokens) and SSH keys

**Cons:**
- (−) **Network Dependency:** Requires internet access for initial `pub get`
- (−) **Resolution Failures:** If GitHub is down or authentication fails,
     builds break
- (−) **Caching Issues:** Pub cache can become stale, requiring manual cleanup
- (−) **Debug Complexity:** Debugging package code is harder (not in workspace)
- (−) **Version Coordination:** Must manually update `ref` to get latest changes

**Long-term Impact:**
- Simplifies project setup and maintenance
- Enables easier team collaboration and onboarding
- Supports CI/CD automation without complex setup
- Potential network dependency issues in offline environments

---

### Option B — Local Path Dependency

**Pros:**
- (+) **Fast Development:** Changes in package immediately available
- (+) **Offline Work:** No network required after initial clone
- (+) **Easy Debugging:** Package code directly accessible in IDE
- (+) **No Version Lag:** Always using latest local version

**Cons:**
- (−) **Non-Portable:** Breaks when directory structure differs
- (−) **Manual Sync:** Must manually update package repository
- (−) **Team Coordination:** Everyone must use same directory layout
- (−) **CI/CD Complexity:** Requires multi-repo checkout scripts
- (−) **Onboarding Friction:** New developers must clone and configure
     multiple repos
- (−) **Version Chaos:** No clear versioning, hard to track what's being used

**Long-term Impact:**
- Increases onboarding time and complexity
- Makes CI/CD pipelines fragile and hard to maintain
- Creates coordination overhead for team development

---

### Option C — Pub.dev Publication

**Pros:**
- (+) **Standard Approach:** Uses Flutter's primary package distribution method
- (+) **Version Management:** Semantic versioning and changelog
- (+) **Caching:** Pub.dev CDN provides fast, reliable downloads
- (+) **Discoverability:** Package is findable by the Flutter community
- (+) **Trust:** Official distribution channel

**Cons:**
- (−) **Public Exposure:** Must make package public or pay for private hosting
- (−) **Release Overhead:** Must publish new versions for every change
- (−) **Maintenance Burden:** Requires maintaining changelogs, versions, etc.
- (−) **Not Suitable for Internal Packages:** Core package is tightly coupled
     to this project
- (−) **Version Delay:** Changes require publishing before use

**Long-term Impact:**
- Adds unnecessary overhead for an internal package
- Forces exposure of proprietary code if made public
- Slows development velocity due to publish-test-release cycles

---

### Option D — Git Submodules

**Pros:**
- (+) **Version Pinning:** Submodules pin to specific commits
- (+) **Single Repo Clone:** Main repo includes submodule reference
- (+) **Standard Git Feature:** No external tools required

**Cons:**
- (−) **Complex Workflow:** Submodules have steep learning curve
- (−) **Common Mistakes:** Easy to commit wrong submodule state
- (−) **Update Friction:** Requires explicit `git submodule update` commands
- (−) **CI/CD Issues:** Recursive clone flags required
- (−) **Team Confusion:** Not all developers familiar with submodules
- (−) **Flutter Integration:** Still requires local path dependency in pubspec

**Long-term Impact:**
- Adds Git complexity without solving the pubspec.yaml portability issue
- Requires team training on submodule workflows
- Doesn't fully leverage Flutter's dependency system

## 6. Consequences

### What Becomes Easier

1. **Onboarding:** New developers can clone the repo and run `flutter pub get`
   without additional setup
2. **CI/CD:** Automated pipelines work out-of-the-box without multi-repo
   configuration
3. **Collaboration:** All team members reference the same version automatically
4. **Version Control:** Specific commits or tags can be pinned for stability
5. **Portability:** Project works on any machine with Git and Flutter installed

### What Becomes Harder

1. **Offline Development:** Initial setup requires internet connection
2. **Package Debugging:** Cannot directly edit package code in IDE (must clone
   separately)
3. **Rapid Iteration:** Changes to core package require committing and updating
   `ref`
4. **Troubleshooting:** Git authentication and network issues can block development

### Accepted Risks

1. **Network Dependency:** GitHub outages or network issues prevent `pub get`
   - **Mitigation:** Pub cache stores resolved dependencies; once cached,
     network not required
2. **Authentication Complexity:** Developers need GitHub access configured
   - **Mitigation:** Provide clear setup guide in QUICK_START.md with both
     HTTPS and SSH options
3. **Stale Cache:** Pub cache may not detect package updates
   - **Mitigation:** Document `flutter pub cache repair` and cache cleanup
     procedures

## 7. Implementation Notes

### Pubspec Configuration

**Basic Configuration (Development):**
```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: main
```

**Recommended Configuration (Production):**
```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: v1.0.0  # Use specific tag for stability
```

**Alternative with Path (Advanced):**
```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: main
      path: packages/core  # If package is in subdirectory
```

### Authentication Options

**HTTPS with Token (Recommended for most users):**
- No special configuration needed for public repos
- For private repos: Use GitHub personal access token in URL or Git credential
  helper

**SSH (Advanced users):**
```yaml
dependencies:
  flutter_package_core:
    git:
      url: git@github.com:arkariz/flutter-package-core.git
      ref: main
```
Requires SSH key configured in GitHub account.

### Version Pinning Strategy

**Development:**
- Use `ref: main` to track latest changes
- Accept rapid iteration and potential breaking changes
- Suitable for active development phases

**Staging/Production:**
- Use `ref: v1.0.0` (specific tag) for stability
- Pin to tested, known-good versions
- Update `ref` deliberately after testing

**Commit Hash (Maximum Stability):**
```yaml
ref: a1b2c3d4e5f6...  # Specific commit SHA
```
Use when absolute stability required (e.g., release builds).

### Common Operations

**Update to Latest Version:**
```bash
# Edit pubspec.yaml to update ref, then:
flutter pub get

# Or force cache update:
flutter pub cache repair
flutter pub get
```

**Clear Cache (Troubleshooting):**
```bash
# Remove cached package
flutter pub cache clean

# Re-download
flutter pub get
```

**Verify Resolved Version:**
```bash
# Check pubspec.lock for exact commit
cat pubspec.lock | grep -A 5 flutter_package_core
```

### Anti-Patterns to Avoid

**❌ DON'T: Leave `ref` unspecified**
```yaml
git:
  url: https://github.com/arkariz/flutter-package-core
  # Missing ref - defaults to HEAD, unpredictable
```

**❌ DON'T: Use short commit hashes**
```yaml
ref: a1b2c3d  # Short hash can be ambiguous
```

**❌ DON'T: Hardcode credentials in pubspec.yaml**
```yaml
url: https://username:password@github.com/...  # Security risk
```

**✅ DO: Use full commit SHAs or tags**
```yaml
ref: v1.0.0  # Tag
# or
ref: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0  # Full SHA
```

**✅ DO: Document current version in comments**
```yaml
dependencies:
  flutter_package_core:
    git:
      url: https://github.com/arkariz/flutter-package-core
      ref: v1.2.0  # Updated 2026-02-08 - Added health sync features
```

### Troubleshooting Guide

**Issue: `Git error. Command: git clone`**

**Cause:** Network connectivity, authentication, or repository access issues.

**Solutions:**
1. Verify network connection to GitHub: `ping github.com`
2. Test Git access: `git ls-remote https://github.com/arkariz/flutter-package-core`
3. Check authentication:
   - HTTPS: Ensure Git credential helper is configured or use personal access token
   - SSH: Verify SSH key is added to GitHub account: `ssh -T git@github.com`
4. Try alternative URL format (switch HTTPS ↔ SSH)
5. Contact repository owner for access if private

**Issue: `version solving failed`**

**Cause:** Dependency conflicts between flutter_package_core and other packages.

**Solutions:**
1. Check `pubspec.lock` for conflicting versions
2. Update other dependencies to compatible versions
3. Use `flutter pub outdated` to identify version issues
4. Temporarily override dependencies if needed

**Issue: Changes in package not reflected**

**Cause:** Pub cache is stale.

**Solutions:**
```bash
flutter pub cache repair
flutter pub get
```

Or clear cache entirely:
```bash
flutter pub cache clean
flutter pub get
```

**Issue: `Could not find a file named "pubspec.yaml"`**

**Cause:** Package repository structure issue or wrong path.

**Solutions:**
1. Verify repository structure on GitHub
2. Check if package is in subdirectory (use `path:` parameter)
3. Ensure `ref` points to valid commit/tag/branch

### CI/CD Integration

**GitHub Actions Example:**
```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.2'

      # Git dependency resolution happens automatically
      - run: flutter pub get

      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

No special configuration needed - git dependencies resolve automatically.

**For Private Repos:**
Add repository access token to secrets and configure Git credential helper
in CI environment.

## 8. Revisit Criteria

This decision should be re-evaluated if:

1. **Package Published to Pub.dev:** If `flutter-package-core` is officially
   published, switch to pub.dev dependency for better caching and versioning
2. **Offline Development Required:** If team frequently works offline (e.g.,
   restricted networks), consider hybrid approach with local mirror
3. **Frequent Package Changes:** If package changes very frequently and
   git dependency update overhead becomes painful, consider local path for
   development with git dependency for CI/CD
4. **Network Issues Persist:** If team experiences chronic GitHub connectivity
   issues, explore alternative hosting (private Git server) or pub.dev private
   hosting
5. **Monorepo Evolution:** If project evolves into true monorepo with multiple
   apps, reconsider overall dependency strategy

## 9. Related Artifacts

- **Quick Start Guide:** `docs/QUICK_START.md` - Includes git dependency setup
  instructions
- **Contributing Guide:** `docs/CONTRIBUTING.md` - Developer workflow with
  git dependencies
- **Repository:** https://github.com/arkariz/flutter-package-core
- **Pubspec:** `pubspec.yaml` - Current dependency configuration

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead, Coder-Docs
**Approved Date:** 2026-02-08
**Implementation Status:** Documented, ready for implementation in pubspec.yaml
