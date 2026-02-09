# Task #3: QA Agent Briefing - Foundation Validation

**Agent Type:** QA (Bash agent)
**Task:** Validate project foundation with `flutter pub get`
**Duration Estimate:** 2-5 minutes
**Complexity:** Low (single command validation)

---

## ✅ Pre-Flight Checklist

Before you start, confirm you've read:
- [x] `.claude/AGENT_CONTEXT.md` (master context)
- [x] `.claude/tasks/task-list.md` (Task #3 definition)
- [x] This briefing file

---

## 🎯 Your Mission

Validate that the scaffolded `health_duel` project foundation is correct by running `flutter pub get` and verifying that **git dependencies resolve successfully**.

This is a **critical checkpoint** before we port 86 core files. If git dependencies fail here, we need user intervention to fix access/config before continuing.

---

## 📚 Required Reading

### Must Read (in order):
1. **`health_duel/pubspec.yaml`** (lines 1-70)
   - Verify git dependency format
   - Note the 5 core packages: exception, network, storage, security, firestore
   - Each uses: `git: {url, ref: main, path: packages/{name}}`

2. **`health_duel/docs/02-architecture/adr/0007-git-dependency-strategy.md`**
   - Understand why we use git deps
   - Know the git repo: `https://github.com/arkariz/flutter-package-core`
   - Understand ref strategy (main vs tags)

### Good to Know:
3. **`.claude/PROGRESS.md`** (section: Phase 2 Step 6)
   - Context: What was done in scaffolding
   - What you're validating

---

## 🔧 Execution Steps

### Step 1: Navigate to Project
```bash
cd "C:\Work Stuff Personal\Project\new-health-duel\health_duel"
pwd  # Verify you're in health_duel/
```

### Step 2: Clean Any Previous State (optional)
```bash
# Only if pubspec.lock or .dart_tool exists
rm -f pubspec.lock
rm -rf .dart_tool
```

### Step 3: Run Dependency Resolution
```bash
flutter pub get
```

**Expected output (success):**
```
Running "flutter pub get" in health_duel...
Resolving dependencies...
+ exception x.x.x from git...
+ network x.x.x from git...
+ storage x.x.x from git...
+ security x.x.x from git...
+ firestore x.x.x from git...
+ [other packages]
Changed X dependencies!
```

### Step 4: Verify Outputs
```bash
# Check that pubspec.lock was created
ls -lh pubspec.lock

# Check that .dart_tool was created
ls -d .dart_tool

# Verify git packages were resolved
grep "git" pubspec.lock | head -10
```

---

## ✅ Success Criteria

Your task is **COMPLETE** when ALL of these are true:
- ✅ `flutter pub get` exits with code 0 (success)
- ✅ `pubspec.lock` file is created
- ✅ `.dart_tool/` directory is created
- ✅ Git packages appear in `pubspec.lock` with resolved versions
- ✅ No error messages about git access or authentication
- ✅ No warnings about conflicting dependencies

---

## ❌ Failure Scenarios & What to Do

### Scenario 1: Git Access Denied
**Error:** `Authentication failed` or `Permission denied (publickey)`

**What to do:**
1. ❌ DO NOT try to fix this yourself
2. ✅ PAUSE immediately
3. ✅ Report to lead agent:
   ```
   BLOCKED: Git authentication failed for flutter-package-core
   Error: [paste full error]
   User needs to configure git credentials or SSH keys.
   ```

### Scenario 2: Git Repo Not Found
**Error:** `Repository not found` or `Could not find package`

**What to do:**
1. ❌ DO NOT change the URL
2. ✅ PAUSE immediately
3. ✅ Report to lead agent:
   ```
   BLOCKED: Git repository not accessible
   URL: https://github.com/arkariz/flutter-package-core
   User needs to verify repo exists and is accessible.
   ```

### Scenario 3: Dependency Conflict
**Error:** `version solving failed` or `conflicting dependencies`

**What to do:**
1. ✅ Capture the full error output
2. ✅ Check which packages are conflicting
3. ✅ Report to lead agent with full details
4. ❌ DO NOT modify pubspec.yaml yourself

### Scenario 4: Network Issues
**Error:** `Failed to download` or `Connection timeout`

**What to do:**
1. ✅ Retry once: `flutter pub get`
2. If still fails → PAUSE and report network issue
3. User may need VPN or proxy configuration

---

## 📊 Reporting Template

### If SUCCESS:
```
✅ Task #3 COMPLETED

Results:
- flutter pub get: SUCCESS (exit code 0)
- pubspec.lock: CREATED (X KB)
- .dart_tool/: CREATED
- Git packages resolved: exception, network, storage, security, firestore

Git package versions:
[paste grep output showing git packages]

Ready to proceed to Task #4 (Port core infrastructure).
```

### If FAILURE:
```
❌ Task #3 BLOCKED

Command: flutter pub get
Exit code: [code]
Error type: [Git access / Repo not found / Dependency conflict / Network]

Full error output:
```
[paste full error]
```

Action required: [describe what user needs to do]

Cannot proceed to Task #4 until this is resolved.
```

---

## 🔍 Verification Commands

After successful `flutter pub get`, run these to verify:

```bash
# 1. Check pubspec.lock exists and shows git deps
head -50 pubspec.lock | grep -A 5 "exception:"

# 2. Verify all 5 core packages resolved
grep -E "(exception|network|storage|security|firestore):" pubspec.lock

# 3. Check Flutter SDK is correct version
flutter --version

# 4. Verify no errors in pub cache
flutter pub cache repair
```

---

## ⚠️ Important Notes

1. **Do NOT modify files**: Your job is validation only. Do not edit pubspec.yaml or any other files.

2. **Do NOT skip reporting**: Even if it succeeds quickly, report the full result with verification.

3. **Do NOT proceed on partial success**: If any of the 5 git packages fails to resolve, that's a failure.

4. **Do NOT improvise**: If you encounter an error not listed here, PAUSE and ask.

5. **Do NOT assume user has git configured**: If git auth fails, user needs to set it up.

---

## 🎓 Background Knowledge

### Why This Step is Critical
- Git dependencies are a **hard requirement** (ADR-0007)
- If they don't work now, Task #4 will fail when porting code
- Better to catch config issues early before copying 86 files
- User might need to configure SSH keys or access tokens

### What Happens Next
If you report success:
- Lead agent will spawn Coder agent for Task #4
- Coder will port 86 core files from reference
- Your validation ensures those files can import flutter-package-core

If you report failure:
- Lead agent will PAUSE and ask user for help
- User will fix git access configuration
- We'll retry Task #3 before continuing

---

## 🚀 Ready to Start?

1. ✅ I've read AGENT_CONTEXT.md
2. ✅ I've read this briefing
3. ✅ I understand the success criteria
4. ✅ I know when to PAUSE and report
5. ✅ I'm ready to execute

**Good luck! Run `flutter pub get` and report back.** 🎯
