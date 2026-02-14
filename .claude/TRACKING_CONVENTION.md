# Progress Tracking Convention

**ATURAN:** Hanya gunakan 2 file ini untuk tracking progress. JANGAN buat file .md random lainnya!

---

## 📋 File Structure (FIXED)

### 1. **PROGRESS.md** - Source of Truth
**Purpose:** Complete project history - apa saja yang sudah dikerjakan
**Update:** Setiap kali selesai task besar atau phase
**Format:**
```
## Phase X: [Name] (STATUS)
### Step/Task [Number] - [Name] ✅/⏳
**Status:** COMPLETED/IN PROGRESS
**Files Created:** X files
**Results:** Brief summary
```

**Contains:**
- Phase completion status
- Task breakdown dengan checkmarks
- File counts dan statistics
- Architecture review scores
- Git commit hashes
- Known issues/TODOs

**DO:**
- ✅ Update saat task selesai
- ✅ Tandai status (✅/⏳)
- ✅ Catat file counts
- ✅ Link ke commit hash

**DON'T:**
- ❌ Bikin file baru dengan tanggal (SESSION_SUMMARY_2026-XX-XX.md)
- ❌ Duplikasi informasi ke file lain
- ❌ Tulis hal yang terlalu detail (cukup summary)

---

### 2. **NEXT_SESSION.md** - Resume Point
**Purpose:** Instruksi singkat untuk lanjut session berikutnya
**Update:** Setiap kali pause/save progress
**Format:**
```
# Next Session

**Status:** [Current phase/task]
**Last Updated:** [Date]

## Resume From Here:
[1-2 sentence context]

## Quick Commands:
- Say: "lanjut" or specific command
- Expected: [what will happen]

## Current Stats:
- Files: X
- Tests: X/X passing
- Build: ✅/❌
```

**Contains:**
- Current status (1 line)
- Resume command
- Quick stats
- Next recommended action

**DO:**
- ✅ Keep it SHORT (max 100 lines)
- ✅ Focus on "what's next"
- ✅ Clear resume instructions

**DON'T:**
- ❌ Copy full session details
- ❌ Duplicate PROGRESS.md content
- ❌ Write long explanations

---

## 🚫 Files to NEVER Create

**BANNED:**
- `SESSION_SUMMARY_YYYY-MM-DD.md` ❌
- `SESSION_LOG_[anything].md` ❌
- `NOTES_[date].md` ❌
- `SUMMARY_[anything].md` ❌
- Any dated tracking files ❌

**Reason:** Creates clutter, inconsistent, hard to find info

---

## ✅ Standard Workflow

### When Task Completed:
1. Update `PROGRESS.md`:
   - Mark task as ✅
   - Add file counts
   - Add commit hash

2. Update `NEXT_SESSION.md`:
   - Update current status
   - Update resume command
   - Update stats

3. **DON'T** create new files!

### When Session Ends:
1. Commit changes (if needed)
2. Update both files above
3. Done! No session summary needed.

### When Resuming:
1. Read `NEXT_SESSION.md` first (resume point)
2. Check `PROGRESS.md` if need context
3. Execute resume command

---

## 📊 Information Hierarchy

**Quick Resume?** → `NEXT_SESSION.md`
**Full History?** → `PROGRESS.md`
**Architecture?** → `docs/02-architecture/`
**Design Docs?** → `.claude/designs/`

---

**REMEMBER:**
- Only 2 files: PROGRESS.md + NEXT_SESSION.md
- No random dated files!
- Keep it simple and consistent!
