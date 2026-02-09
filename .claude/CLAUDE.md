# CLAUDE.md — Health Duel Project Context

## Resume Instructions
This is an ongoing project with an active execution plan. **DO NOT start from scratch.**
Read the plan file and memory file, then continue from where we left off.

- **Progress Overview**: `.claude/PROGRESS.md` (high-level status)
- **Execution Plan**: `.claude/plans/execution-plan.md` (full plan)
- **Task List**: `.claude/tasks/task-list.md` (current tasks)
- **Memory/Context**: `.claude/memory/MEMORY.md` (agent context)

## Current Progress
- Phase 1 — DONE (Documentation complete, essential docs only)
- Phase 2 Step 5-6 — DONE (Analyzer extracted 86 files, Project scaffolded)
- Phase 2 Step 7 — NEXT: QA Validation (flutter pub get) ← RESUME HERE
- Phase 2 Step 8 — Pending (Port core infrastructure)
- Phases 3-4 — Pending

## Agent Onboarding Protocol

**CRITICAL FOR ALL SPAWNED AGENTS:**
Every agent spawned for this project MUST read `.claude/AGENT_CONTEXT.md` BEFORE starting any work.
This master context file contains essential project information, architecture rules, and constraints.

**Reading Order for Agents:**
1. `.claude/AGENT_CONTEXT.md` (MASTER - always first)
2. `.claude/agents/task-{N}-{role}-brief.md` (Task-specific briefing)
3. Additional docs listed in the briefing

Lead agent: When spawning any agent, explicitly include this reading order in the prompt.

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
