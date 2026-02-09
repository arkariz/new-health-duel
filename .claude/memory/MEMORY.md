# Health Duel Project Memory

## Project Overview
- Flutter mobile app for social 24-hour step-count competitions
- Reference project at: `reference_project/fintrack_lite/`
- New project will be at: `health_duel/` (same working dir)
- All Dart source already uses `package:health_duel` — files can be copied verbatim
- Use git dep `https://github.com/arkariz/flutter-package-core` instead of local monorepo

## Current Status
- **Phase 1 DONE**: Documentation complete (essential docs for agent implementation)
  - Core docs: README, ARCHITECTURE_OVERVIEW, PRD, PROJECT_GLOSSARY
  - ADRs: 0001-0004 (patterns), 0007 (git deps)
  - Skipped human-facing docs (ENVIRONMENT_SETUP, FIREBASE_SETUP, SECURITY, ROADMAP, CHEATSHEET)
- **Phase 2 IN PROGRESS**: Project Foundation & Core Port
  - Step 5 (Task #1): ✅ Analyzer extracted 86 core files from reference
  - Step 6 (Task #2): ✅ Project scaffolded with git dependencies
  - Step 7 (Task #3): ⏳ NEXT - QA validation (flutter pub get)
  - Step 8 (Task #4): ⏳ Pending - Port core infrastructure
- Phases 3-4 pending

## Plan File
Full execution plan: `C:\Users\arkariz\.claude\plans\prancy-herding-pascal.md`

## Agent Team Structure
Specialized role-based agents:
- **Lead**: Orchestrates all work
- **Analyzer**: Deep-dives reference code (uses `flutter-expert` skill)
- **Planner**: Designs architecture (uses `flutter-expert`, `mobile-design`, `ui-ux-pro-max`, `doc-coauthoring` skills)
- **Coder**: Writes/ports code (uses `flutter-expert`, `mobile-design`, `ui-ux-pro-max`, `docs-writer` skills)
- **Reviewer**: Reviews architecture & code quality (uses `flutter-expert` skill)
- **QA**: Runs builds, tests, static analysis (uses `flutter-expert` skill)
- **Fixer**: Resolves issues found by Reviewer/QA (uses `flutter-expert` skill)

Workflow: `Analyzer → Planner → Coder(s) → Reviewer → QA → Fixer (if needed)`

## Key Decisions
- Documentation-first approach: enhance docs BEFORE porting any code
- Duel feature details NOT in plan — Planner agent will design at runtime
- If git dep blocks, PAUSE and ask user for help
- User prefers Indonesian language for conversation

## Analyzer Findings Summary
- Existing docs scored 7.6/10, found phase contradictions, duplicate content
- 12 undocumented code patterns identified (side effect extensions, atomic user bootstrap, etc.)
- 6 missing documents identified (Security, Testing Strategy, Deployment, etc.)
- Complete EffectBloc pattern documented (5-part system)
- Full Auth feature template extracted end-to-end

## Tech Stack
Flutter 3.7.2+, Dart, flutter_bloc, get_it, go_router, dartz, equatable, Firebase (Auth+Firestore), health plugin
