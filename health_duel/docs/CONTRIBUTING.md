# Contributing to Health Duel

Thank you for your interest in contributing to Health Duel. This guide provides
everything you need to know to contribute effectively to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Documentation Standards](#documentation-standards)
- [Testing Requirements](#testing-requirements)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Architecture Decision Records](#architecture-decision-records)

## Code of Conduct

We are committed to providing a welcoming and professional environment for all
contributors. By participating in this project, you agree to:

- Use respectful and inclusive language
- Focus on constructive feedback
- Respect differing viewpoints and experiences
- Prioritize the project's goals over individual preferences

## Getting Started

Before contributing, complete these steps:

1. **Set up your development environment**
   - Follow the [Quick Start Guide](QUICK_START.md) to set up the project
   - Verify you can build and run the app successfully

2. **Understand the project**
   - Read [Foundational Context](00-foundation/FOUNDATIONAL_CONTEXT.md) for the project vision
   - Study [Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md) for system design
   - Review [Project Glossary](00-foundation/PROJECT_GLOSSARY.md) for terminology

3. **Find an issue or feature to work on**
   - Check the issue tracker for open issues
   - Look for issues labeled `good first issue` if you're new
   - Discuss major changes before implementing them

## Development Workflow

Follow this workflow for all code contributions:

### 1. Create a Feature Branch

Create a new branch from `main` using the naming convention:

```bash
git checkout main
git pull origin main
git checkout -b <type>/<short-description>
```

**Branch naming patterns:**
- `feature/duel-creation` - New features
- `fix/auth-crash` - Bug fixes
- `refactor/bloc-pattern` - Code refactoring
- `docs/update-readme` - Documentation updates
- `test/add-unit-tests` - Test additions

### 2. Make Your Changes

Follow these principles while coding:
- Write clean, readable code
- Follow [Coding Standards](#coding-standards)
- Add tests for new functionality
- Update documentation as needed
- Keep changes focused and atomic

### 3. Test Your Changes

Before committing, ensure:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Code is formatted: `dart format .`
- [ ] App builds successfully: `flutter build apk` or `flutter build ios`
- [ ] Manual testing completed for changed features

### 4. Commit Your Changes

Follow [Commit Guidelines](#commit-guidelines) for commit messages:

```bash
git add <files>
git commit -m "feat: add duel creation flow"
```

### 5. Push and Create Pull Request

```bash
git push origin <branch-name>
```

Then create a pull request following the [Pull Request Process](#pull-request-process).

## Coding Standards

Maintain consistent code quality by adhering to these standards:

### Dart and Flutter Conventions

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use the official [Flutter style guide](https://flutter.dev/docs/development/style)
- Run `dart format .` before committing
- Ensure `flutter analyze` reports zero issues

### Clean Architecture Principles

Health Duel follows Clean Architecture with strict layer separation:

```
lib/
├── core/              # Cross-cutting concerns
├── data/              # Data layer (repositories, data sources, models)
├── domain/            # Domain layer (entities, use cases, repository interfaces)
└── features/          # Presentation layer (UI, BLoC, widgets)
```

**Key rules:**
- **Domain layer** has zero dependencies on other layers
- **Data layer** depends only on domain
- **Presentation layer** depends on domain (not data directly)
- Use dependency injection (GetIt) for loose coupling

### State Management (BLoC)

Use the EffectBloc pattern for state management:

```dart
// Define states
sealed class DuelState extends Equatable {}
final class DuelInitial extends DuelState {}
final class DuelLoading extends DuelState {}
final class DuelLoaded extends DuelState {
  final Duel duel;
  DuelLoaded(this.duel);
}

// Define events
sealed class DuelEvent extends Equatable {}
final class LoadDuel extends DuelEvent {
  final String duelId;
  LoadDuel(this.duelId);
}

// Define effects (side effects like navigation, snackbars)
sealed class DuelEffect extends UiEffect {}
final class ShowDuelError extends DuelEffect {
  final String message;
  ShowDuelError(this.message);
}
```

For detailed patterns, see [Development Patterns](03-development/patterns/).

### Naming Conventions

- **Classes:** PascalCase (`UserRepository`, `DuelBloc`)
- **Variables/Functions:** camelCase (`getUserById`, `currentUser`)
- **Constants:** lowerCamelCase (`maxDuelDuration`)
- **Private members:** Prefix with underscore (`_privateMethod`)
- **Files:** snake_case (`user_repository.dart`)

### Code Organization

- One class per file (exceptions for sealed classes and small related classes)
- Group imports: Dart SDK, Flutter, external packages, internal imports
- Order class members: constants, fields, constructors, methods
- Keep files under 300 lines when possible

### Error Handling

Use the `Either` type from `dartz` for error handling:

```dart
Future<Either<Failure, Duel>> createDuel(DuelParams params) async {
  try {
    final duel = await _dataSource.createDuel(params);
    return Right(duel);
  } on CoreException catch (e) {
    return Left(ExceptionMapper.toFailure(e));
  }
}
```

Never use raw exceptions in domain or presentation layers.

## Documentation Standards

Documentation is a first-class citizen in Health Duel. Follow these standards
for all documentation contributions:

### Voice and Tone

- Address the reader as "you"
- Use active voice and present tense
- Keep tone professional yet conversational
- Avoid jargon, or define it in the glossary
- Use contractions (don't, it's) for friendliness

### Formatting

- Wrap text at 80 characters (except long links or code)
- Use sentence case for headings
- Start every heading with an overview paragraph before sub-sections or lists
- Use numbered lists for sequential steps, bullets for non-sequential items
- Use **bold** for UI elements, `code font` for code, filenames, and commands

### Structure

- Start documents with a clear introduction (BLUF - Bottom Line Up Front)
- Use hierarchical headings (h1 → h2 → h3, don't skip levels)
- Include "Next Steps" section at the end when applicable
- Cross-reference related documents with relative links

### Code Examples

- Use realistic, meaningful names (avoid "foo", "bar")
- Include context (imports, class definitions) when necessary
- Add comments to explain non-obvious logic
- Test all code examples to ensure they work

### Markdown Guidelines

```markdown
# Document Title (H1 - only one per document)

Brief introduction paragraph.

## Main Section (H2)

Overview of this section.

### Subsection (H3)

Detailed content.

**Bold for emphasis**, *italic for terms*, `code for technical elements`.

- Bullet lists for non-sequential items
- Keep items parallel in structure

1. Numbered lists for sequential steps
2. Start with imperative verbs

> **Note:** Use blockquotes for important notes.

[Link text](relative/path/to/document.md) for internal links.
```

## Testing Requirements

All contributions must include appropriate tests:

### Unit Tests

- Test all domain logic (use cases, entities)
- Test repository implementations
- Test BLoC event handlers and state emissions
- Mock external dependencies using `mockito`

**Example:**
```dart
void main() {
  group('CreateDuel', () {
    late CreateDuel useCase;
    late MockDuelRepository mockRepository;

    setUp(() {
      mockRepository = MockDuelRepository();
      useCase = CreateDuel(mockRepository);
    });

    test('should create duel successfully', () async {
      // Arrange
      final params = DuelParams(/*...*/);
      when(mockRepository.createDuel(params))
          .thenAnswer((_) async => Right(testDuel));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(testDuel));
      verify(mockRepository.createDuel(params));
    });
  });
}
```

### Widget Tests

- Test widget rendering for different states
- Test user interactions (taps, swipes, form inputs)
- Test navigation flows

### Integration Tests

- Test critical user journeys end-to-end
- Test Firebase integration points
- Test health data synchronization

### Coverage Goals

- Maintain minimum 80% code coverage for domain and data layers
- Maintain minimum 60% coverage for presentation layer
- Run coverage report: `flutter test --coverage`

## Commit Guidelines

Use conventional commit format for clear, semantic commit history:

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code formatting, missing semicolons (no code change)
- `refactor` - Code refactoring without feature change
- `test` - Adding or updating tests
- `chore` - Build process, dependency updates

### Scope (optional)

Feature or module affected: `auth`, `duel`, `health`, `core`, `ui`

### Subject

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 50 characters

### Body (optional)

- Wrap at 72 characters
- Explain what and why, not how
- Reference issues or PRs

### Examples

```bash
feat(duel): add 24-hour countdown timer

Implement real-time countdown display for active duels.
Updates every minute using stream builder.

Closes #42
```

```bash
fix(auth): resolve login crash on invalid email

Handle FirebaseAuthException properly to prevent app crash
when user enters malformed email address.
```

```bash
docs: update architecture overview with health module

Add health module architecture diagram and data flow.
Clarifies HealthKit and Health Connect integration.
```

## Pull Request Process

Follow these steps to submit a pull request:

### 1. Pre-submission Checklist

Before creating a PR, ensure:
- [ ] All tests pass locally
- [ ] Code is formatted and analyzed
- [ ] Documentation is updated
- [ ] Commit messages follow guidelines
- [ ] Branch is up to date with `main`

### 2. Create Pull Request

Use this PR template:

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #<issue-number>

## Changes Made
- Detailed list of changes
- Impacts on existing functionality

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed
- [ ] All tests pass

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No analyzer warnings
- [ ] Reviewed my own code
```

### 3. Review Process

Your PR will be reviewed by maintainers:
- Expect feedback within 2-3 business days
- Address review comments promptly
- Discuss disagreements constructively
- Be open to suggestions and alternative approaches

### 4. Merging

Once approved:
- Squash commits if requested
- Ensure CI/CD pipeline passes
- Maintainer will merge the PR

## Architecture Decision Records

For significant architectural decisions, create an ADR:

### When to Create an ADR

Create an ADR when making decisions about:
- State management approach
- Data persistence strategy
- API design patterns
- Security implementations
- Performance optimizations
- Third-party integrations

### ADR Process

1. Copy the template:
   ```bash
   cp docs/02-architecture/adr/0000-template.md \
      docs/02-architecture/adr/XXXX-decision-title.md
   ```

2. Fill out all sections:
   - Context: Why this decision is needed
   - Decision: What was decided
   - Options Considered: Alternatives evaluated
   - Trade-offs: Pros and cons of each option
   - Consequences: Impact on the codebase

3. Number ADRs sequentially (0001, 0002, etc.)

4. Submit ADR as part of your PR or as a separate documentation PR

### ADR Example

See [ADR-004: Registry-Based UI Effect Flow Architecture](02-architecture/adr/0004-registry-based-ui-effect-flow-architecture.md)
for a complete example.

## Additional Resources

- [Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md) - System design
- [Development Patterns](03-development/patterns/) - Code patterns
- [Testing Strategy](08-testing/) - Testing approach
- [Project Glossary](00-foundation/PROJECT_GLOSSARY.md) - Terminology

## Questions or Issues?

If you have questions about contributing:
1. Check this guide and linked documentation
2. Search existing issues and discussions
3. Create a new issue with the `question` label
4. Reach out to the maintainers

Thank you for contributing to Health Duel! Your efforts help build a better,
healthier community through technology.

---

**Last Updated:** 2026-02-08
**Version:** 1.0
