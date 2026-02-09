# Health Duel Documentation

Welcome to the Health Duel project documentation. This comprehensive guide
provides everything you need to understand, build, and contribute to the Health
Duel mobile application.

## What is Health Duel?

Health Duel is a Flutter mobile application that enables friends to compete in
24-hour step-count competitions. Challenge your friends, track progress in
real-time, and celebrate healthy habits through fun, social competition.

## Quick Navigation

### Getting Started
- **[Quick Start Guide](QUICK_START.md)** ⭐ Start here for setup instructions
- **[Contributing Guidelines](CONTRIBUTING.md)** - How to contribute to the project
- **[Project Glossary](00-foundation/PROJECT_GLOSSARY.md)** - Key terms and definitions

### Foundation
- **[Foundational Context](00-foundation/FOUNDATIONAL_CONTEXT.md)** - Project vision, goals, and engineering principles
- **[Architecture Vision](00-foundation/ARCHITECTURE_VISION.md)** - High-level architecture philosophy and design principles
- **[Project Glossary](00-foundation/PROJECT_GLOSSARY.md)** - Domain and technical terminology

### Product
- **[Product Requirements Document](01-product/prd-health-duels-1.0.md)** - Complete product specification for MVP v1.0
- **[User Stories](01-product/user-stories.md)** - Detailed user stories with acceptance criteria

### Architecture
- **[Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md)** - System architecture and design patterns
- **[Architecture Decision Records (ADRs)](02-architecture/adr/)** - Documented architectural decisions

### Development
- **[Development Patterns](03-development/patterns/)** - Code patterns and best practices
- **[Feature Implementation Guides](05-guides/feature-guides/)** - Step-by-step feature development guides

### Testing
- **[Testing Strategy](08-testing/)** - Testing approach and test templates

### Operations
- **[Environment Configuration](09-operations/environments/)** - Environment setup and deployment

## Documentation Structure

This documentation is organized into logical sections:

```
docs/
├── README.md              # This file - documentation hub
├── QUICK_START.md         # Fast setup guide (< 10 minutes)
├── CONTRIBUTING.md        # Contribution guidelines
├── 00-foundation/         # Project vision, principles, glossary
├── 01-product/            # PRD, user stories, product specs
├── 02-architecture/       # Architecture docs and ADRs
├── 03-development/        # Development patterns and practices
├── 04-planning/           # Project plans and roadmaps
├── 05-guides/             # How-to guides and tutorials
├── 06-technical-specs/    # Detailed technical specifications
├── 07-research/           # Research notes and findings
├── 08-testing/            # Testing strategy and templates
├── 09-operations/         # Deployment and ops guides
├── 10-maintenance/        # Session notes and change logs
└── 99-templates/          # Document templates
```

## How to Use This Documentation

### For New Developers
1. Read the [Quick Start Guide](QUICK_START.md) to set up your environment
2. Review [Foundational Context](00-foundation/FOUNDATIONAL_CONTEXT.md) to understand the project vision
3. Study the [Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md) to grasp the system design
4. Check [Contributing Guidelines](CONTRIBUTING.md) before making changes

### For Product Managers
1. Review the [Product Requirements Document](01-product/prd-health-duels-1.0.md)
2. Check [User Stories](01-product/user-stories.md) for feature details
3. Reference the [Project Glossary](00-foundation/PROJECT_GLOSSARY.md) for terminology

### For Architects and Senior Engineers
1. Study [Architecture Decision Records](02-architecture/adr/) to understand key decisions
2. Review [Architecture Vision](00-foundation/ARCHITECTURE_VISION.md) for design principles
3. Check [Development Patterns](03-development/patterns/) for implementation standards

### For QA Engineers
1. Read the [Testing Strategy](08-testing/) for testing approach
2. Use [Test Templates](08-testing/test-templates/) for consistent test cases
3. Reference [Feature Guides](05-guides/feature-guides/) for feature specifications

## Documentation Standards

All documentation in this project follows these standards:
- **Voice:** Active voice, present tense, addressing "you"
- **Clarity:** Simple vocabulary, no jargon without definition
- **Format:** Markdown with proper headings, lists, and code blocks
- **Links:** Relative links between documents for easy navigation
- **Structure:** Overview paragraphs before lists or sub-headings

For detailed documentation standards, see [Contributing Guidelines](CONTRIBUTING.md).

## Finding What You Need

### Search by Topic
- **Setup:** QUICK_START.md, 09-operations/environments/
- **Architecture:** 02-architecture/, 00-foundation/ARCHITECTURE_VISION.md
- **Features:** 01-product/, 05-guides/feature-guides/
- **Patterns:** 03-development/patterns/
- **Testing:** 08-testing/
- **Decisions:** 02-architecture/adr/

### Common Questions
- *How do I get started?* → [Quick Start Guide](QUICK_START.md)
- *What is the project vision?* → [Foundational Context](00-foundation/FOUNDATIONAL_CONTEXT.md)
- *How is the app architected?* → [Architecture Overview](02-architecture/ARCHITECTURE_OVERVIEW.md)
- *What are the product requirements?* → [Product Requirements Document](01-product/prd-health-duels-1.0.md)
- *What terms should I know?* → [Project Glossary](00-foundation/PROJECT_GLOSSARY.md)
- *How do I contribute?* → [Contributing Guidelines](CONTRIBUTING.md)

## Keeping Documentation Updated

Documentation is a living artifact that evolves with the codebase. When making
code changes, update relevant documentation:
- New features → Update PRD, user stories, feature guides
- Architecture changes → Create ADR, update architecture docs
- New patterns → Document in 03-development/patterns/
- Bug fixes → Update maintenance notes if significant

See [Contributing Guidelines](CONTRIBUTING.md) for the documentation update process.

## Project Status

- **Current Phase:** Phase 1 - Foundation & Documentation
- **Next Phase:** Phase 2 - Core Feature Implementation
- **Target Timeline:** 12 months to production-ready MVP

For detailed progress tracking, see [04-planning/phase-plans/](04-planning/phase-plans/).

## Need Help?

If you can't find what you're looking for:
1. Use your IDE's search to find keywords across all documentation
2. Check the [Project Glossary](00-foundation/PROJECT_GLOSSARY.md) for term definitions
3. Review the section-specific README files in each directory
4. Ask the team for guidance

## Contributing to Documentation

We welcome documentation improvements! See [Contributing Guidelines](CONTRIBUTING.md)
for how to propose changes, follow standards, and submit documentation updates.

---

**Last Updated:** 2026-02-08
**Documentation Version:** 1.0
**Project Version:** MVP v1.0 (In Development)
