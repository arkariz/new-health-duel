# CLAUDE.md — Health Duel Project Context

**Last Updated:** 2026-02-27
**Current Phase:** Phase 5 - UI Redesign (Step 4)

---

## 📊 Quick Status

**Check here first:** `.claude/STATUS.md` (single source of truth, git-synced)

**Current State:**
- Phase: 5 - UI Redesign 🎨
- Step: 4 - Duel Screens Redesign
- Latest Commit: `39b3d93` - Home refactor
- Next: Redesign Active Duel, List, Create, Result screens

---

## 🎯 Agent Reading Protocol

### **CRITICAL: All spawned agents MUST read in this order:**

#### 🔴 Tier 1: MUST READ (Before ANY work)
1. **`.claude/AGENT_CONTEXT.md`** (5 min)
   - Architecture rules, constraints, standards
   - What you MUST/MUST NOT do
   - **READ FIRST, ALWAYS**

2. **`.claude/STATUS.md`** (3 min)
   - Current project state (Phase/Step/Status)
   - Git-synced progress (latest commits)
   - Next actions
   - **SINGLE SOURCE OF TRUTH**

3. **`.claude/tasks/task-list.md`** (2 min)
   - Active tasks for current phase
   - Your assignment & acceptance criteria

**Total: 10 min → READY TO START**

#### 🟡 Tier 2: CONTEXT (Read based on role)

**For Coder/Fixer:**
- `health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md` - Clean Architecture
- `health_duel/docs/02-architecture/adr/0004-*.md` - EffectBloc pattern
- `health_duel/docs/02-architecture/adr/0002-*.md` - Error handling
- `health_duel/docs/00-foundation/PROJECT_GLOSSARY.md` - Naming conventions

**For Planner:**
- `.claude/designs/phase-4-duel-architecture.md` - Design example
- `health_duel/docs/01-product/prd-health-duels-1.0.md` - Product spec
- All 8 ADRs in `health_duel/docs/02-architecture/adr/`

**For Reviewer:**
- All 8 ADRs (review criteria)
- `.claude/TRACKING_CONVENTION.md` - How to update STATUS.md

#### 🟢 Tier 3: OPTIONAL (Reference as needed)
- `.claude/plans/execution-plan.md` - Full plan (use STATUS.md instead)
- Skills: `flutter-expert`, `mobile-design`, `ui-ux-pro-max`, `docs-writer`
- Product docs, user stories, architecture vision

#### 🔵 Tier 4: ARCHIVED (Read-only, historical)
- `.claude/archive/PROGRESS.md` - Old tracking (replaced by STATUS.md)
- `.claude/archive/CHECKPOINT.md` - Old checkpoint
- `.claude/archive/NEXT_SESSION.md` - Old resume guide
- Old agent briefs in `.claude/agents/` (Phase 2-3)

---

## 🚀 Quick Lookup

| Need | File |
|------|------|
| **Current status** | `.claude/STATUS.md` |
| **Architecture rules** | `.claude/AGENT_CONTEXT.md` |
| **My task** | `.claude/tasks/task-list.md` |
| **Clean Architecture** | `health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md` |
| **EffectBloc pattern** | `health_duel/docs/02-architecture/adr/0004-*.md` |
| **Error handling** | `health_duel/docs/02-architecture/adr/0002-*.md` |
| **Naming** | `health_duel/docs/00-foundation/PROJECT_GLOSSARY.md` |
| **Product spec** | `health_duel/docs/01-product/prd-health-duels-1.0.md` |

---

## 🤖 When Spawning Agents

**Lead Agent: Include this prompt for all spawned agents:**

```
CRITICAL - Read these files BEFORE starting work:
1. .claude/AGENT_CONTEXT.md (architecture rules)
2. .claude/STATUS.md (current project state)
3. .claude/tasks/task-list.md (your assignment)

[Then add role-specific reading list from Tier 2 above]
```

## Agent Team Workflow
Use specialized role-based agents via Task tool:
1. **Analyzer** (Explore agent) — reads reference code, extracts patterns
2. **Planner** (Plan agent) — designs architecture, docs structure
3. **Coder** (general-purpose agent) — writes/ports code
4. **Reviewer** (Explore agent) — reviews architecture & code quality
5. **QA** (Bash agent) — runs flutter analyze, test, build
6. **Fixer** (general-purpose agent) — resolves issues

Skills to invoke per agent:
- Planner: `flutter-expert`, `doc-coauthoring`, `mobile-design`, `ui-ux-pro-max`
- Coder: `flutter-expert`, `docs-writer`, `mobile-design`, `ui-ux-pro-max`
- Reviewer: `flutter-expert`

## Project Facts
- Reference project: `reference_project/fintrack_lite/`
- New project target: `health_duel/` in this directory
- All Dart imports already use `package:health_duel` — copy verbatim
- Use git dep: `https://github.com/arkariz/flutter-package-core`
- If git dep resolution fails → PAUSE and ask user
- Flutter + Dart, Clean Architecture, BLoC (EffectBloc pattern), GetIt DI, GoRouter, Firebase

## User Preferences
- Indonesian language for conversation is OK
- Documentation-first: enhance docs BEFORE porting code
- Duel feature spec created by Planner at runtime, not hardcoded in plan
