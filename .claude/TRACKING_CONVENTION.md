# Progress Tracking Convention v2.0

**Revised:** 2026-02-27
**Prinsip:** Git is Truth, Minimal Files, Auto-sync

---

## 📋 New File Structure

### **SINGLE SOURCE OF TRUTH:**

```
.claude/
├── STATUS.md              ← ONLY tracking file (max 200 lines)
├── memory/MEMORY.md       ← Auto memory (system-managed, don't edit)
├── tasks/task-list.md     ← Task tool output (optional, for active sprints)
└── archive/               ← Old tracking files (read-only)
    ├── PROGRESS.md        ← Archived (was 512 lines, too long)
    ├── CHECKPOINT.md      ← Archived (duplicate of PROGRESS)
    └── NEXT_SESSION.md    ← Archived (outdated quickly)
```

---

## 📄 STATUS.md - The One File

**Purpose:** Git-aware project status dashboard
**Update Trigger:** After git commit OR phase/step change
**Max Length:** 200 lines (force brevity)

### **Sections:**
1. **Current State** (5 lines)
   - Phase, Step, Status, Next Action

2. **Phase Progress Table** (10 lines)
   - All phases, status, commit hash, date

3. **Current Phase Details Table** (varies)
   - Steps breakdown for active phase only

4. **Project Stats** (10 lines)
   - Files, tests, build status, features

5. **Recent Activity** (15 lines)
   - Last 10 git commits (auto from `git log --oneline -10`)

6. **Next Steps** (20 lines)
   - Immediate actions (current step)
   - After current phase

7. **Known Issues** (5 lines)
   - Blocking issues only
   - TODOs for future

8. **Quick Commands** (10 lines)
   - Resume, QA, status check

9. **Key Documents** (10 lines)
   - Links to architecture, design, context

---

## ✅ Update Workflow

### **After Git Commit:**
```bash
# Auto-update git info in STATUS.md:
1. Update "Latest Commit" header
2. Update "Recent Activity" from git log
3. Mark step/phase as ✅ if done
4. Update commit hash in phase table
```

### **When Phase/Step Changes:**
```bash
1. Update "Current State" section
2. Update status emoji (🔄/✅)
3. Update "Next Steps"
4. Archive old phase details if needed
```

### **When Session Ends:**
```bash
# Nothing extra needed!
# STATUS.md already has all info for resume
```

---

## 🚫 Files to NEVER Create

**BANNED:**
- ❌ `PROGRESS.md` (archived, use STATUS.md)
- ❌ `CHECKPOINT.md` (archived, duplicate)
- ❌ `NEXT_SESSION.md` (archived, outdated quickly)
- ❌ `SESSION_SUMMARY_*.md` (clutter)
- ❌ Any dated tracking files
- ❌ Any "resume guide" files

**Why STATUS.md is better:**
- ✅ Git-aware (pulls from commits)
- ✅ Compact (max 200 lines vs 512)
- ✅ Single truth (no conflicts)
- ✅ Self-documenting (all sections in one place)
- ✅ Easy to scan (tables + emojis)

---

## 📊 Information Hierarchy

**Quick Resume?** → `STATUS.md` (Current State + Next Steps)
**Full Context?** → `STATUS.md` (Phase Progress + Recent Activity)
**Git History?** → `git log` (STATUS.md syncs from this)
**Architecture?** → `docs/02-architecture/`
**Auto Memory?** → `.claude/memory/MEMORY.md` (don't edit manually)

---

## 🔄 Auto-Sync Strategy

**STATUS.md learns from:**
1. **Git log** → Recent Activity section (auto)
2. **Git status** → Current branch, clean/dirty state
3. **Test output** → Project Stats (manual after `flutter test`)
4. **Build output** → Project Stats (manual after `flutter build`)

**MEMORY.md learns from:**
- System auto-saves important decisions, patterns, user preferences
- Don't manually duplicate STATUS.md content there
- Use MEMORY.md for "lessons learned", not "current status"

---

## 🎯 Migration Done

**Old System:**
- PROGRESS.md (512 lines, outdated details)
- CHECKPOINT.md (264 lines, duplicate)
- NEXT_SESSION.md (69 lines, outdated quickly)
- **Total:** 845 lines, 3 files to maintain

**New System:**
- STATUS.md (150 lines, git-aware)
- **Total:** 150 lines, 1 file to maintain

**Savings:** 82% less content, 67% fewer files, 100% more accurate

---

**REMEMBER:**
- ✅ One file: STATUS.md
- ✅ Git is truth: commits > manual notes
- ✅ Max 200 lines: force brevity
- ✅ Auto-sync: from git log
- ❌ No manual history: git already tracks that
