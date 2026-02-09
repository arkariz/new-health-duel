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
- ✅ Phase 1: Documentation (essential docs complete)
- 🔄 Phase 2: Foundation & Core Port (IN PROGRESS - 50% done)
  - ✅ Task #1: Analyzer extracted 86 core files
  - ✅ Task #2: Project scaffolded with git deps
  - ⏳ Task #3: NEXT - QA validation (flutter pub get)
  - ⏳ Task #4: Pending - Port core infrastructure
- ⏳ Phase 3: Port features (Auth, Home, Health)
- ⏳ Phase 4: Build Duel feature

**Read full status:** `.claude/PROGRESS.md`

---

## 📚 Essential Documents (Know Where to Find Info)

### For ALL Agents:
1. **`.claude/AGENT_CONTEXT.md`** ← You are here
2. **`.claude/tasks/task-list.md`** - Your task definition & requirements
3. **`.claude/PROGRESS.md`** - High-level project status
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
| My task definition | `.claude/tasks/task-list.md` |
| My task briefing | `.claude/agents/task-{N}-{role}-brief.md` |
| Project status | `.claude/PROGRESS.md` |
| Full plan | `.claude/plans/execution-plan.md` |
| Architecture patterns | `health_duel/docs/02-architecture/ARCHITECTURE_OVERVIEW.md` |
| EffectBloc pattern | `health_duel/docs/02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md` |
| Error handling | `health_duel/docs/02-architecture/adr/0002-exception-isolation-strategy.md` |
| Git deps strategy | `health_duel/docs/02-architecture/adr/0007-git-dependency-strategy.md` |
| Naming conventions | `health_duel/docs/00-foundation/PROJECT_GLOSSARY.md` |
| Reference code | `reference_project/fintrack_lite/lib/` |
| Analyzer findings | Task #1 output (ask lead if needed) |

---

## 📊 Project Structure Reference

```
new-health-duel/
├── .claude/                      ← All agent context & progress
│   ├── AGENT_CONTEXT.md         ← YOU ARE HERE (read first)
│   ├── agents/                   ← Task briefings
│   ├── tasks/task-list.md       ← Task definitions
│   ├── PROGRESS.md              ← Project status
│   └── plans/execution-plan.md  ← Full implementation plan
├── health_duel/                  ← Target Flutter project
│   ├── docs/                     ← Architecture docs
│   ├── lib/                      ← Source code (scaffolded, mostly empty)
│   ├── android/, ios/, web/      ← Platform configs (copied)
│   └── pubspec.yaml              ← Dependencies (git deps configured)
└── reference_project/
    └── fintrack_lite/            ← Reference implementation (READ ONLY)
```

---

## 🎯 Your Next Steps

1. ✅ You've read this master context
2. 📖 Read `.claude/tasks/task-list.md` to find your task
3. 📋 Read your task briefing: `.claude/agents/task-{N}-{role}-brief.md`
4. 📚 Read required architecture docs (listed in your briefing)
5. 🚀 Execute your task following the briefing instructions
6. ✅ Report completion or issues to lead agent

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
