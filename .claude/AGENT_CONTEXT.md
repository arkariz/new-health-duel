# Agent Context - Health Duel Project

**READ THIS FIRST** - Every agent working on this project must read this file before starting any task.

---

## 🎯 Project Overview

**Health Duel** is a Flutter mobile app for social 24-hour step-count competitions.

- **Reference Project:** `reference_project/fintrack_lite/` (completed Phases 1-4)
- **Target Project:** `health_duel/` (being recreated with improvements)
- **Current Phase:** Phase 2 - Project Foundation & Core Port
- **Last Updated:** 2026-02-09

---

## 📍 Current Status (Quick Reference)

**Phase Progress:**
- ✅ Phase 1-4.5: COMPLETED (Foundation, Features, Duel, Auth cleanup)
- 🔄 Phase 5: UI Redesign (IN PROGRESS - Step 4)
  - ✅ Step 1: Design tokens (AppTheme + Colors)
  - ✅ Step 2: Auth screens (Login + Register)
  - ✅ Step 3: Home screen (refactored to widgets)
  - 🔄 Step 4: CURRENT - Duel screens redesign
- ⏳ Phase 6-8: Testing, Firebase, Production

**Latest Commit:** `39b3d93` - Home refactor

**Read full status:** `.claude/STATUS.md` (git-synced, single source of truth)

---

## 📚 Essential Documents (Know Where to Find Info)

### For ALL Agents:
1. **`.claude/AGENT_CONTEXT.md`** ← You are here (READ FIRST)
2. **`.claude/STATUS.md`** - Current project state (SINGLE SOURCE OF TRUTH)
3. **`.claude/tasks/task-list.md`** - Your task definition & requirements
4. **`health_duel/docs/00-foundation/PROJECT_GLOSSARY.md`** - Naming conventions

### For Implementation (Coder, Reviewer, Fixer):
5. **`health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md`** - System architecture
6. **`health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md`** - Error handling
7. **`health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md`** - EffectBloc pattern
8. **`health_duel/docs/02-architecture/adr/0007-git-dependency-strategy.md`** - Git dependencies

### For Your Specific Task:
9. **`.claude/agents/task-{N}-{role}-brief.md`** - Your task briefing (if exists)

---

## 🎓 Critical Knowledge (Must Know)

### Architecture Principles
- **Clean Architecture:** 3 layers (domain, data, presentation)
- **Dependency Rule:** Dependencies point inward (domain has ZERO Flutter imports)
- **EffectBloc Pattern:** 5-part system for side effects (see ADR-0004)
- **Either<Failure, T>:** All repository methods return Either type (functional error handling)
- **DI Registration Order:** core → session → auth → home → health → router

### Code Standards
- **Package Name:** `package:health_duel` (already correct in all reference files)
- **Bundle IDs:** `com.example.health_duel` (Android & iOS)
- **Import Style:** Always use `package:health_duel/...` (never relative imports for features)
- **No Flutter in Domain:** Domain layer is pure Dart

### Git Dependencies
- **flutter-package-core:** Use git dep from `https://github.com/arkariz/flutter-package-core`
- **Format:** `git: {url, ref: main, path: packages/{name}}`
- **Packages:** exception, network, storage, security, firestore
- **See:** ADR-0007 for full strategy

### Naming Conventions
- **Entities:** User, StepCount, Duel, Challenge
- **Failures:** NetworkFailure, ServerFailure, AuthFailure, etc.
- **Effects:** ShowSnackBarEffect, NavigateGoEffect, ShowDialogEffect
- **BLoCs:** AuthBloc, HomeBloc, HealthBloc, DuelBloc
- **See:** PROJECT_GLOSSARY.md for complete list

---

## 🚫 Critical Constraints (DO NOT Violate)

### What You MUST Do:
✅ Read `.claude/tasks/task-list.md` to understand your task
✅ Read your specific agent briefing (`.claude/agents/task-{N}-*.md`)
✅ Follow Clean Architecture boundaries strictly
✅ Use Either<Failure, T> for all repository methods
✅ Use EffectBloc pattern for all BLoCs (not plain Bloc)
✅ Copy imports verbatim from reference (already use `package:health_duel`)
✅ PAUSE and report if you encounter blocking issues (especially git deps)

### What You MUST NOT Do:
❌ Import Flutter in domain layer (presentation → data → domain, never reverse)
❌ Use local path dependencies (only git deps for flutter-package-core)
❌ Create new patterns (follow existing patterns from reference)
❌ Skip reading required documents (you will make mistakes)
❌ Continue if blocked (PAUSE and report to lead agent)
❌ Modify reference project files (only read, never write to `reference_project/`)

---

## 🔍 Where to Find Specific Information

| Need to Know | Document Location |
|--------------|-------------------|
| **Current status** | `.claude/STATUS.md` ← **START HERE** |
| My task definition | `.claude/tasks/task-list.md` |
| My task briefing | `.claude/agents/task-{N}-{role}-brief.md` |
| Full plan | `.claude/plans/execution-plan.md` (use STATUS.md instead) |
| Architecture patterns | `health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md` |
| EffectBloc pattern | `health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md` |
| Error handling | `health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md` |
| Git deps strategy | `health_duel/docs/02-architecture/adr/0007-git-dependency-strategy.md` |
| Naming conventions | `health_duel/docs/00-foundation/PROJECT_GLOSSARY.md` |
| Reference code | `reference_project/fintrack_lite/lib/` |

---

## 📊 Project Structure Reference

```
new-health-duel/
├── .claude/                      ← All agent context & progress
│   ├── CLAUDE.md                ← User/Lead entry point + reading protocol
│   ├── AGENT_CONTEXT.md         ← YOU ARE HERE (read first)
│   ├── STATUS.md                ← SINGLE SOURCE OF TRUTH (git-synced)
│   ├── tasks/task-list.md       ← Active tasks
│   ├── agents/                   ← Task briefings (some archived)
│   ├── plans/execution-plan.md  ← Full plan (use STATUS.md instead)
│   ├── archive/                  ← Old tracking (PROGRESS, CHECKPOINT, NEXT_SESSION)
│   └── TRACKING_CONVENTION.md   ← How to update STATUS.md
├── health_duel/                  ← Target Flutter project
│   ├── docs/                     ← Architecture docs (ADRs, PRD, etc.)
│   ├── lib/                      ← Source code (164 Dart files)
│   ├── android/, ios/, web/      ← Platform configs
│   └── pubspec.yaml              ← Dependencies (git deps configured)
└── reference_project/
    └── fintrack_lite/            ← Reference implementation (READ ONLY)
```

---

## 🎯 Your Next Steps

1. ✅ You've read this master context (AGENT_CONTEXT.md)
2. 📊 Read `.claude/STATUS.md` to know current project state
3. 📖 Read `.claude/tasks/task-list.md` to find your task
4. 📋 Read your task briefing: `.claude/agents/task-{N}-{role}-brief.md` (if exists)
5. 📚 Read required architecture docs (based on your role - see CLAUDE.md Tier 2)
6. 🚀 Execute your task following the briefing instructions
7. ✅ Report completion or issues to lead agent

---

## 🆘 If You Need Help

**When to PAUSE and ask for help:**
- Git dependency resolution fails
- You don't understand a pattern from the docs
- You encounter unexpected errors
- Your task briefing is missing or unclear
- You're unsure if an action violates constraints

**How to report:**
- Clearly state what you were trying to do
- Include the error message or issue
- Mention which documents you've read
- Wait for lead agent guidance

---

## 🔐 Quality Standards

Every agent is expected to:
- ✅ Read all required documents before starting
- ✅ Follow patterns from reference project exactly
- ✅ Write clear, documented code
- ✅ Test your changes (if applicable)
- ✅ Report progress and completion
- ✅ PAUSE when blocked (don't guess or improvise)

---

**Remember:** This is a documentation-first, architecture-strict project. Quality over speed. When in doubt, read the docs or ask.

**Good luck! 🚀**
