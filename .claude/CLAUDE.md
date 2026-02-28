# CLAUDE.md — Health Duel Project Context

**Last Updated:** 2026-02-27
**Current Phase:** Phase 5 - UI Redesign (Step 4)

---

## 🚀 Quick Lookup

| Need | File |
|------|------|
| **Architecture rules** | `.claude/AGENT_CONTEXT.md` |
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
