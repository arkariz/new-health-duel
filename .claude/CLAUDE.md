# CLAUDE.md — Health Duel Project Context

## Resume Instructions
This is an ongoing project with an active execution plan. **DO NOT start from scratch.**
Read the plan file and memory file, then continue from where we left off.

- **Execution Plan**: `C:\Users\arkariz\.claude\plans\prancy-herding-pascal.md`
- **Memory/Progress**: See auto-memory MEMORY.md

## Current Progress
- Phase 1 Step 1 (Analyzer) — DONE
- Phase 1 Step 2 (Planner: Design enhanced docs) — IN PROGRESS ← RESUME HERE
- Phase 1 Step 3-4 — Pending
- Phase 2-4 — Pending

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
