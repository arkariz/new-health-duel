# Architecture Vision

This document defines the high-level architecture philosophy, design principles,
and quality goals that guide all technical decisions in the Health Duel project.

## Purpose

The architecture vision serves as:
- A north star for technical decision-making
- A reference for evaluating architectural trade-offs
- A foundation for Architecture Decision Records (ADRs)
- A guide for consistent system design across features

## Core Philosophy

Health Duel is built with the philosophy that **engineering excellence is
demonstrated through scalable, maintainable, and testable code**, not just
working features. Every architectural decision prioritizes long-term
maintainability over short-term convenience.

### Key Tenets

1. **Clarity over cleverness**: Simple, explicit code beats clever abstractions
2. **Testability is mandatory**: If it can't be tested, it can't be trusted
3. **Boundaries enforce discipline**: Layer separation prevents technical debt
4. **Decisions are documented**: Context matters as much as the choice
5. **Patterns promote consistency**: Established patterns reduce cognitive load

## Design Principles

### 1. Clean Architecture

Health Duel strictly follows Clean Architecture with three distinct layers:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │  ← Widgets, BLoC, UI
│  (Depends on Domain only)           │
├─────────────────────────────────────┤
│         Data Layer                  │  ← Repositories, Data Sources, DTOs
│  (Implements Domain interfaces)     │
├─────────────────────────────────────┤
│        Domain Layer                 │  ← Entities, Use Cases, Interfaces
│  (Pure Dart, zero dependencies)     │
└─────────────────────────────────────┘
```

**Dependency Rule:** Dependencies point inward only. Domain depends on nothing.
Data and Presentation depend on Domain but never on each other.

**Benefits:**
- Domain logic is framework-agnostic and easily testable
- Data sources can be swapped without affecting business logic
- UI can be redesigned without touching core logic
- Clear boundaries prevent coupling and technical debt

**Enforcement:**
- Domain layer: Only Dart SDK + utility packages (dartz, equatable)
- Data layer: Can depend on Firebase, network, storage packages
- Presentation layer: Can depend on Flutter and UI packages

Related: See [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md)
for detailed layer specifications.

### 2. SOLID Principles

Every class and module adheres to SOLID principles:

**Single Responsibility Principle (SRP)**
- Each class has one reason to change
- Use cases do one thing well
- Repositories handle one data source
- BLoCs manage one feature's state

**Open/Closed Principle (OCP)**
- Extend behavior through composition, not modification
- Use sealed classes for exhaustive type handling
- Define interfaces in domain, implement in data

**Liskov Substitution Principle (LSP)**
- Implementations fully honor interface contracts
- Mock repositories behave identically to real ones for tests

**Interface Segregation Principle (ISP)**
- Repositories expose only methods needed by use cases
- BLoCs define minimal event and state interfaces

**Dependency Inversion Principle (DIP)**
- High-level modules (domain) define interfaces
- Low-level modules (data) implement those interfaces
- Dependency injection inverts control flow

### 3. Separation of Concerns

Clear boundaries prevent feature sprawl and maintain focus:

**Feature Boundaries**
- Each feature is self-contained in its directory
- Features communicate through domain entities, not internal state
- Shared logic lives in core, not duplicated across features

**Layer Boundaries**
- Presentation layer handles user interaction and UI state
- Data layer handles persistence, network, and external APIs
- Domain layer handles business logic and validation

**Cross-Cutting Concerns**
- Centralized in core modules: error handling, routing, theming, DI
- Configured once, used everywhere
- No feature-specific error handling or theming logic

### 4. Functional Error Handling

Health Duel treats errors as data, not exceptions:

**Either Type**
- All fallible operations return `Either<Failure, Success>`
- `Left` contains domain-level Failure (never raw exceptions)
- `Right` contains success value
- Forces explicit error handling at every call site

**Failure Hierarchy**
- Sealed class hierarchy represents all error categories
- Failures are domain concepts: NetworkFailure, ServerFailure, CacheFailure
- ExceptionMapper converts technical exceptions to domain Failures
- UI displays user-friendly messages based on Failure type

**Benefits:**
- No unexpected crashes from unhandled exceptions
- Error handling is explicit and type-safe
- Business logic is pure and deterministic
- Failures are easily tested and mocked

Related: See ADR-002 for exception isolation strategy.

### 5. Reactive State Management

State is managed reactively using the BLoC pattern with EffectBloc extension:

**BLoC Pattern**
- UI dispatches Events to BLoC
- BLoC processes Events and emits States
- UI rebuilds in response to State changes
- No direct state mutation from UI

**EffectBloc Extension**
- Adds support for one-time side Effects
- Effects represent actions (navigation, snackbars, dialogs)
- Effects are consumed once, States persist until replaced
- Clear separation between state and side effects

**Benefits:**
- Predictable state changes
- Easy to test (Events in, States out)
- Time-travel debugging with bloc_observer
- Clear separation between persistent state and transient effects

Related: See ADR-004 for EffectBloc pattern specification.

### 6. Dependency Injection

All dependencies are injected, never constructed:

**GetIt Service Locator**
- Single global registry for all dependencies
- Lazy singleton registration for most services
- Factory registration for stateful instances
- Feature modules register their dependencies

**Benefits:**
- Easy to swap implementations (prod vs test)
- Dependencies are explicit and visible
- Testability through mock injection
- No hidden dependencies or singletons

**Usage Pattern:**
```dart
// Module registration
void setupDuelModule() {
  getIt.registerLazySingleton(() => CreateDuel(getIt()));
  getIt.registerLazySingleton<DuelRepository>(() => DuelRepositoryImpl(getIt()));
}

// BLoC instantiation
final duelBloc = DuelBloc(
  createDuel: getIt(),
  getDuel: getIt(),
);
```

## Quality Goals

### Maintainability

**Goal:** Code should be easy to understand, modify, and extend.

**Strategies:**
- Clear naming conventions (intent over implementation)
- Small, focused classes and methods
- Consistent patterns across features
- Comprehensive documentation and ADRs
- Code reviews for every change

**Metrics:**
- Class complexity (cyclomatic complexity < 10)
- Method length (< 50 lines)
- File length (< 300 lines when possible)
- Consistent code formatting (dart format)

### Testability

**Goal:** Every component should be easily testable in isolation.

**Strategies:**
- Dependency injection for all external dependencies
- Pure functions with no side effects in domain layer
- Interface-based design for easy mocking
- Separation of logic from framework code

**Metrics:**
- Domain/Data layers: 80%+ code coverage
- Presentation layer: 60%+ code coverage
- All public APIs have tests
- Critical paths have integration tests

### Scalability

**Goal:** Architecture should support growth in features and users.

**Strategies:**
- Feature-based code organization
- Lazy loading for dependencies and routes
- Efficient data structures and algorithms
- Pagination for large data sets
- Caching strategies for frequently accessed data

**Metrics:**
- App startup time < 2 seconds
- Smooth 60fps UI with no jank
- Memory usage < 100MB for typical use
- Network requests minimized through caching

### Performance

**Goal:** App should be fast, responsive, and battery-efficient.

**Strategies:**
- Minimize build method complexity
- Use const constructors where possible
- Implement efficient data structures
- Background processing for heavy operations
- Image caching and optimization
- Lazy loading for large lists

**Metrics:**
- Flutter DevTools performance profiling
- Frame rendering < 16ms (60fps)
- Memory leaks detection
- Battery usage monitoring

### Security

**Goal:** User data and health information must be protected.

**Strategies:**
- Encrypted storage for sensitive data
- Secure Firebase rules for Firestore access
- Input validation at domain layer
- Secure authentication flow
- HTTPS for all network requests
- Regular security audits

**Standards:**
- No secrets in code (use environment variables)
- Health data access with explicit permissions
- Firestore security rules tested and reviewed
- Dependencies regularly updated for security patches

## Technology Choices

### Core Framework: Flutter

**Rationale:**
- Single codebase for iOS and Android
- Native performance with compiled code
- Rich widget ecosystem
- Strong community and Google backing
- Excellent tooling (DevTools, hot reload)

**Trade-offs:**
- Larger app size compared to native
- Platform-specific features require method channels
- Accepted for cross-platform efficiency

### State Management: BLoC

**Rationale:**
- Clear separation of business logic and UI
- Testability through Events and States
- Integration with Flutter's reactive framework
- Established patterns and best practices
- DevTools support for debugging

**Trade-offs:**
- More boilerplate than simpler solutions
- Learning curve for new developers
- Accepted for maintainability and scalability

Related: See ADR-004 for EffectBloc pattern decision.

### Backend: Firebase

**Rationale:**
- Rapid MVP development without custom backend
- Real-time data sync with Firestore
- Built-in authentication
- Push notifications via FCM
- Serverless Cloud Functions
- Free tier suitable for MVP

**Trade-offs:**
- Vendor lock-in to Firebase ecosystem
- Cost scaling at high user counts
- Less control than custom backend
- Accepted for MVP speed and simplicity

### Dependency Injection: GetIt

**Rationale:**
- Simple service locator pattern
- No code generation required
- Minimal boilerplate
- Flutter-independent (pure Dart)
- Well-established in Flutter community

**Trade-offs:**
- No compile-time dependency validation
- Runtime errors if dependencies missing
- Accepted for simplicity and flexibility

### Error Handling: Dartz

**Rationale:**
- Functional error handling with Either type
- Forces explicit error handling
- Type-safe and composable
- Common pattern in Clean Architecture
- Pure Dart, framework-agnostic

**Trade-offs:**
- Functional programming learning curve
- Verbose compared to try-catch
- Accepted for reliability and testability

Related: See ADR-002 for exception isolation strategy.

## Architectural Constraints

These constraints guide all implementation decisions:

### Hard Constraints (Must Follow)

1. **Domain layer purity**: Domain code must have zero Flutter dependencies
2. **Dependency direction**: Dependencies must point inward only
3. **No direct data layer access**: Presentation must use use cases only
4. **Either for fallible operations**: All operations that can fail return Either
5. **Sealed classes for variants**: Events, States, Failures, Effects use sealed classes

### Soft Constraints (Follow Unless ADR Overrides)

1. **File organization**: Follow feature-based structure
2. **Naming conventions**: Follow Dart and Flutter style guides
3. **Test coverage**: Aim for 80%+ in domain/data, 60%+ in presentation
4. **Documentation**: Document all public APIs and non-obvious logic
5. **Code review**: All changes reviewed before merge

## Architectural Evolution

Architecture is not static. It evolves as the project grows.

### When to Revisit Decisions

Create a new ADR or update architecture documents when:
- Adding significant new features or modules
- Encountering limitations of current patterns
- Performance or scalability issues emerge
- Technology landscape changes (new packages, Flutter versions)
- Team feedback indicates pain points

### Evolution Principles

- **Incremental change**: Evolve gradually, don't rewrite
- **Backward compatibility**: Maintain existing contracts during transition
- **Document reasons**: Explain why change is needed, not just what changed
- **Validate with prototypes**: Prove new patterns before widespread adoption
- **Communicate widely**: Ensure team understands and agrees with changes

### Planned Evolutions

Known areas for future architectural evolution:
- **Offline-first architecture**: Robust offline support with sync
- **Multi-platform expansion**: Web and desktop support
- **Modularization**: Extract reusable packages
- **Performance optimization**: Profile and optimize hot paths
- **Advanced testing**: Visual regression, performance tests

## Related Documents

- [Foundational Context](FOUNDATIONAL_CONTEXT.md) - Project vision and goals
- [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md) - Detailed architecture
- [Development Patterns](../03-development/patterns/) - Implementation patterns
- [ADR Index](../02-architecture/adr/) - Architectural decisions with trade-offs

## Success Indicators

The architecture is successful when:
- [ ] New features can be added without modifying existing code
- [ ] Bugs are isolated to single features or layers
- [ ] Tests are easy to write and maintain
- [ ] Onboarding new developers takes < 1 week
- [ ] Code reviews focus on logic, not structure
- [ ] Performance meets or exceeds targets
- [ ] Security audits find no critical issues
- [ ] Technical debt remains manageable

---

**Last Updated:** 2026-02-08
**Version:** 1.0
**Status:** Active - Guiding Phase 1 Development
