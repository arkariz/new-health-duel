# FOUNDATIONAL PLANNING CONTEXT: Senior Flutter Engineer Roadmap

> **Status:** Active Reference
> **Target Timeline:** 12 Months
> **Project Vehicle:** 24-Hour Health Duels
> **Current Codebase:** `health_duel/` (ported from reference project)
> **Current Phase:** Phase 1 (Foundation & Documentation)

## 1. The Objective

Transform into a **Senior Flutter Engineer** & **Technical Decision Maker**
within 12 months. Moving beyond "making it work" to "making it scale,
maintainable, and secure".

## 2. Core Principles

*   **Engineering Excellence**: Functionality is just the baseline. The real
    goals are **scalability, modularity, and maintainability**.
*   **Practical Implementation**: Theory is useless without application. Every
    concept must be implemented in code.
*   **Deep Work**: Dedicate **2 days/week** to intense, focused technical study
    and implementation.
*   **Clean Architecture**: Adhere strictly to separation of concerns (Data,
    Domain, Presentation). No shortcuts.

## 3. The Vehicle: 24-Hour Health Duels

A social health competition app where friends compete in 24-hour step challenges.

*   **Purpose**: Not just to track steps, but to demonstrate **engineering
    excellence** through real-world integrations (HealthKit/Health Connect,
    Firebase, Push Notifications).
*   **Infrastructure**: Built upon the custom git dependency
    **`flutter-package-core`** + Firebase backend.
*   **PRD Reference**: See `docs/01-product/prd-health-duels-1.0.md` for
    complete product requirements.

### What Makes Health Duels Different

Health Duels is designed as a **learning vehicle** that demonstrates senior-level
engineering skills:

1. **Real-world complexity**: Integrates health data, real-time sync, push
   notifications, and social features
2. **Production-ready architecture**: Clean Architecture with proper separation
   of concerns
3. **Scalable patterns**: EffectBloc pattern, dependency injection, repository
   pattern
4. **Platform integration**: Native HealthKit (iOS) and Health Connect (Android)
   integration
5. **Cloud infrastructure**: Firebase Auth, Firestore, Cloud Functions, and FCM

### Duel Feature Goals

The core duel feature enables:
- **24-hour competitions**: Fast, focused challenges that fit into daily life
- **Step-count metric**: Simple, universal health metric everyone understands
- **Head-to-head competition**: Social accountability through friend challenges
- **Real-time updates**: Live progress tracking and lead change notifications
- **Shareable results**: Social proof and bragging rights through share cards

This feature demonstrates mastery of:
- Complex state management across multiple screens
- Real-time data synchronization with Firestore
- Background health data collection and sync
- Push notification delivery and handling
- Dynamic UI generation for share cards
- Robust error handling and offline support

## 4. Technical Stack & Focus Areas

### Foundation (`flutter-package-core`) ✅ Integrated

Fully utilization of the custom git dependency packages:

*   **`exception`**: Centralized, rule-based error handling utilizing
    `CoreException`.
*   **`network`**: Dio with Builder pattern, Interceptors, and robust
    configuration.
*   **`storage`**: Hive-based abstraction with built-in encryption.
*   **`security`**: AES-256 encryption utilities.
*   **`firestore`**: Advanced wrapper handling batch operations, transactions,
    and real-time updates.

### Health Duels Specific Technologies

*   **Health Integration**: `health` plugin for HealthKit (iOS) and Health
    Connect (Android)
*   **Firebase Stack**: Auth, Firestore, Cloud Messaging (FCM), Cloud Functions
*   **Push Notifications**: Real-time duel updates and lead changes
*   **Deep Links**: Duel invitation sharing
*   **Share Cards**: Dynamic image generation for social sharing

### Advanced Concepts to Master

*   **System Design**: Designing scalable modules.
*   **Advanced State Management**: Managing complex state (BLoC pattern with
    EffectBloc).
*   **Native Integration**: Writing platform-specific code (Method Channels)
    when needed.
*   **Performance**: Profiling, optimizing rendering, and memory management.
*   **DevOps**: CI/CD pipelines for automated testing and deployment.

## 5. Current Project Status

### Project Phase: Phase 1 - Foundation & Documentation

Health Duel is currently in Phase 1, focusing on:
- Enhanced documentation creation
- Architecture planning and design
- Reference codebase analysis
- Pattern extraction and standardization

**Next Phase:** Phase 2 - Core Feature Implementation (Auth, Health, Duel MVP)

### Core Infrastructure Status

Based on the reference project (`fintrack_lite/`), the following infrastructure
will be ported to Health Duel:

**Core Infrastructure (`health_duel/lib/core/`)** - ⏳ Pending Port
```
core/
├── config/           Configuration, storage keys, environment flavors
├── di/               GetIt dependency injection, CoreModule
├── error/            Failures (sealed), ExceptionMapper
├── router/           GoRouter setup with route configuration
├── theme/            AppTheme, Design Tokens (see ADR-005)
│   ├── tokens/       AppSpacing, AppRadius, AppDurations
│   └── extensions/   AppColorsExtension (light/dark mode)
├── bloc/             EffectBloc, UiEffect, EffectListener (see ADR-004)
├── presentation/     Shimmer, Error views, Responsive widgets
└── utils/extensions/ Modular extensions (Context, DateTime, List, Num, String)
```

**Global Shared Data Layer (`health_duel/lib/data/`)** - ⏳ Pending Port
```
data/
└── session/          Global session management
    ├── data/         SessionDataSource, UserModel, SessionRepositoryImpl
    ├── domain/       User entity, SessionRepository, GetCurrentUser, SignOut
    └── di/           SessionModule
```

**Feature Structure Planned**
```
features/
├── auth/             ⏳ Pending (Login, Register, Sign Out)
├── home/             ⏳ Pending (Dashboard with duel overview)
├── health/           ⏳ Pending (HealthKit/Health Connect integration)
├── duel/             ⏳ Pending (Core MVP - creation, active, results)
├── notifications/    ⏳ Pending (FCM integration)
├── share/            ⏳ Pending (Share card generation)
└── friends/          ⏳ Pending (Friend management)
```

## 6. Decision Documentation

### Architecture Decision Records (ADR)

All significant architectural decisions MUST be documented as ADRs in
`docs/02-architecture/adr/`.

**ADR Template Structure:**
- **Metadata**: Decision ID, date, roadmap phase, status, scope
- **Context**: Why the decision exists, constraints, problems
- **Decision**: Explicit statement of what was decided
- **Options Considered**: Alternatives genuinely evaluated
- **Trade-offs Analysis**: Pros, cons, long-term impact of each option
- **Consequences**: What becomes easier/harder, accepted risks
- **Implementation Notes**: Practical guidance, anti-patterns
- **Revisit Criteria**: When to re-evaluate the decision

**Planned ADRs for Health Duel:**

Reference project ADRs will be reviewed and adapted:
- ADR-001: Selective Caching Strategy
- ADR-002: Exception Isolation Strategy
- ADR-003: Hybrid Storage Key Strategy
- ADR-004: Registry-Based UI Effect Flow Architecture
- ADR-005: Design Token Strategy
- ADR-006: Thin Use Cases for Health Phase

Additional ADRs will be created for Health Duel-specific decisions:
- Health data sync strategy
- Duel state management approach
- Push notification handling
- Offline support strategy

**Purpose:** ADRs demonstrate engineering maturity by:
1. Making implicit decisions explicit
2. Recording trade-offs and context
3. Preventing future "why did we do this?" confusion
4. Supporting learning and knowledge transfer

## 7. Development Approach

### Documentation-First Philosophy

Health Duel follows a **documentation-first approach**:
1. **Plan before code**: Design architecture and document decisions
2. **Document patterns**: Extract and standardize code patterns
3. **Write specifications**: Define feature requirements before implementation
4. **Create guides**: Provide clear implementation guides for developers

This approach ensures:
- Clear understanding of requirements and architecture
- Consistent implementation across features
- Easier onboarding for new developers
- Better maintainability and knowledge transfer

### Agent-Based Development

Development uses specialized agents for different tasks:
- **Analyzer**: Deep-dives reference code, extracts patterns
- **Planner**: Designs architecture and documentation structure
- **Coder**: Implements features following documented patterns
- **Reviewer**: Reviews code quality and architecture adherence
- **QA**: Tests functionality and runs static analysis
- **Fixer**: Resolves issues identified by Reviewer and QA

This workflow ensures:
- Thorough analysis before implementation
- Consistent quality across all code
- Proper separation of concerns
- Systematic issue resolution

## 8. Learning Objectives

Through building Health Duel, you will master:

### Technical Skills
- Clean Architecture implementation at scale
- Advanced state management with BLoC/EffectBloc
- Firebase integration (Auth, Firestore, Cloud Functions, FCM)
- Native platform integration (HealthKit, Health Connect)
- Offline-first architecture with sync strategies
- Real-time data handling and conflict resolution
- Push notification implementation
- Dynamic content generation (share cards)
- CI/CD pipeline setup and management

### Engineering Skills
- System design and architecture planning
- Trade-off analysis and decision documentation
- Code pattern extraction and standardization
- Technical writing and documentation
- Test-driven development
- Performance profiling and optimization
- Security best practices
- DevOps and deployment automation

### Professional Skills
- Technical decision-making
- Architecture review and critique
- Knowledge transfer through documentation
- Code review and quality assurance
- Project planning and estimation
- Stakeholder communication

## 9. Interaction Guidelines for AI

*   **Be a Peer**: Communicate as a Senior Engineer to another. Discuss
    **trade-offs**, design patterns, and "Why", not just "How".
*   **Challenge Assumptions**: If a user request violates Clean Architecture or
    scalability principles, **flag it** and propose a better engineering solution.
*   **Architecture First**: Always map requests back to the architectural
    blueprint before writing code.
*   **Document Decisions**: Create ADRs for all significant architectural
    choices.
*   **Test-Driven**: Ensure tests are written for all new functionality.
*   **Quality Over Speed**: Prioritize maintainable, scalable solutions over
    quick fixes.

## 10. Success Criteria

By the end of 12 months, success is measured by:

### Technical Deliverables
- [ ] Production-ready Health Duel MVP deployed to app stores
- [ ] Comprehensive test coverage (>80% for domain/data, >60% for presentation)
- [ ] Complete documentation including ADRs, guides, and API references
- [ ] CI/CD pipeline with automated testing and deployment
- [ ] Zero critical security vulnerabilities
- [ ] Performance benchmarks met (app startup <2s, smooth 60fps UI)

### Engineering Competencies
- [ ] Ability to design scalable system architectures independently
- [ ] Make and document architectural decisions with trade-off analysis
- [ ] Implement complex features following Clean Architecture principles
- [ ] Write comprehensive technical documentation
- [ ] Review and critique code and architecture effectively
- [ ] Debug and optimize performance issues systematically
- [ ] Set up and manage DevOps infrastructure

### Professional Growth
- [ ] Demonstrate senior-level technical leadership
- [ ] Communicate technical concepts clearly to stakeholders
- [ ] Mentor junior developers through documentation and code reviews
- [ ] Contribute to technical decision-making in projects
- [ ] Build and maintain production-grade applications

## 11. Next Steps

To continue with Health Duel development:

1. **Review Documentation**: Study the enhanced documentation structure
2. **Understand Architecture**: Deep-dive into architecture decisions and patterns
3. **Plan Implementation**: Break down features into manageable tasks
4. **Port Core Infrastructure**: Begin with core modules from reference project
5. **Implement Features**: Build features incrementally following Clean Architecture
6. **Test Thoroughly**: Write comprehensive tests for each layer
7. **Document Progress**: Update documentation as implementation progresses

For detailed development plans, see:
- [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md)
- [Product Requirements](../01-product/prd-health-duels-1.0.md)
- [Development Patterns](../03-development/patterns/)
- [Implementation Guides](../05-guides/feature-guides/)

---

**Last Updated:** 2026-02-08
**Version:** 1.0
**Status:** Active - Phase 1 in Progress
