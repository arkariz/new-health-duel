# 🏃 24-Hour Health Duels

> **Challenge friends. Compete in 24 hours. Win bragging rights.**

A social health competition app where friends compete in 24-hour step challenges. Built with **Clean Architecture**, **modular design patterns**, and a focus on **engineering excellence**.

![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean-brightgreen)
![State](https://img.shields.io/badge/State-BLoC-blueviolet)

---

## 📱 Overview

24-Hour Health Duels transforms daily fitness into an engaging social experience. Instead of lonely step tracking, users challenge friends to head-to-head competitions with real-time updates and shareable results.

### Key Features

- 🎯 **24-Hour Duels** - Time-boxed competitions that create urgency
- 👥 **Head-to-Head** - Direct challenges between friends
- 📊 **Live Progress** - Real-time step tracking via HealthKit/Health Connect
- 🔥 **Real-time Sync** - Firestore-backed live step count updates during duels
- 🏆 **Duel Results** - Winner declaration with step count comparison

---

## 🏗️ Architecture

This project demonstrates **production-grade Flutter architecture** with strict separation of concerns.

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  • BLoC (State Management)      • Widgets (UI)              │
│  • Side Effects                 • Design Tokens             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  • Entities (Pure Dart)         • Use Cases (Business Logic)│
│  • Repository Interfaces        • Value Objects             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│  • Repository Implementations  • Data Sources               │
│  • DTOs / Models               • Exception → Failure Mapping│
│  • Firebase Integration        • Real-time Streams          │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/                      # Shared infrastructure
│   ├── bloc/                  # EffectBloc base class (side effects)
│   ├── config/                # App configuration, env, storage keys
│   ├── di/                    # Dependency injection (GetIt)
│   ├── error/                 # Failure types, exception mapping
│   ├── presentation/          # Reusable UI components
│   ├── router/                # GoRouter navigation + AppRoutes
│   ├── theme/                 # Design system & tokens
│   └── utils/                 # Extensions & utilities
│
├── data/                      # Global shared data layer
│   └── session/               # User session, UserModel, value objects
│
└── features/                  # Feature modules (vertical slices)
    ├── auth/                  # Authentication (Google, Apple, Email)
    ├── health/                # HealthKit / Health Connect integration
    ├── home/                  # Dashboard & navigation hub
    └── duel/                  # Duel lifecycle (create, active, result)
```

### Feature Module Structure

Each feature follows a consistent structure for predictability and maintainability:

```
feature/
├── data/
│   ├── datasources/           # Remote & local data sources
│   ├── models/                # DTOs with serialization
│   └── repositories/          # Interface implementations
├── domain/
│   ├── entities/              # Rich domain models
│   ├── repositories/          # Abstract interfaces
│   ├── usecases/              # Business logic orchestration
│   └── value_objects/         # Validated value types
├── presentation/
│   ├── bloc/                  # Events, States, Side Effects
│   ├── pages/                 # Screen widgets
│   └── widgets/               # Feature-specific components
└── di/                        # Feature dependency registration
```

---

## 🔧 Technical Stack

### Core Infrastructure

Built on a custom **`flutter-package-core`** git dependency for reusable infrastructure:

| Package | Purpose |
|---------|---------|
| `exception` | Centralized exception types with classification rules |
| `network` | Dio wrapper with builder pattern & interceptors |
| `storage` | Hive abstraction with encryption support |
| `security` | AES-256 encryption utilities |
| `firestore` | Advanced Firestore wrapper (batch, transactions) |

### External Dependencies

| Category | Package | Version | Purpose |
|----------|---------|---------|---------|
| **State** | `flutter_bloc` | ^8.1.6 | Predictable state management |
| **DI** | `get_it` | ^8.0.0 | Service locator pattern |
| **Routing** | `go_router` | ^14.6.0 | Declarative navigation |
| **Health** | `health` | ^13.1.3 | HealthKit & Health Connect integration |
| **Firebase** | `firebase_auth` | ^5.3.4 | Authentication |
| **Firebase** | `cloud_firestore` | ^5.6.0 | Real-time database |
| **Functional** | `dartz` | ^0.10.1 | Either type for error handling |

---

## 🏥 Health Integration

### Platform Support

| Platform | Source | Permissions |
|----------|--------|-------------|
| **iOS** | HealthKit | Steps (read) |
| **Android** | Health Connect | Steps (read) |

### Permission Flow

```
┌──────────────┐    ┌─────────────────┐     ┌──────────────┐
│   App Start  │──> │ Check Permission│───> │  Authorized  │
└──────────────┘    └─────────────────┘     └──────────────┘
                            │                       │
                            ▼                       ▼
                    ┌───────────────┐        ┌─────────────┐
                    │ Not Determined│        │ Fetch Steps │
                    └───────────────┘        └─────────────┘
                            │
                            ▼
                  ┌────────────────────┐
                  │ Request Permission │
                  └────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.2+
- Xcode 15+ (iOS)
- Android Studio with Health Connect SDK

### Setup

```bash
# Clone repository
git clone https://github.com/arkariz/health_duel.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Configuration

Create `.env` files in `env/` directory:

```
# env/.env.dev
FIREBASE_API_KEY=your_dev_key
FIREBASE_PROJECT_ID=your_dev_project

# env/.env.prod
FIREBASE_API_KEY=your_prod_key
FIREBASE_PROJECT_ID=your_prod_project
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific feature tests
flutter test test/features/auth/
```

### Test Structure

```
test/
├── core/
│   └── error/                 # Failure types & ExceptionMapper tests
├── features/
│   └── auth/
│       ├── bloc/              # AuthBloc unit tests
│       └── presentation/      # LoginPage widget tests
└── helpers/                   # Mocks, fixtures, pumpApp utilities
```

---

## 📊 State Management

Using **EffectBloc pattern** — a custom extension of BLoC for type-safe one-shot side effects:

```dart
// Effects are emitted alongside state, consumed once by EffectListener
class AuthBloc extends EffectBloc<AuthEvent, AuthState> {

  Future<void> _onSignInRequested(event, emit) async {
    emit(const AuthLoading());

    final result = await _signInWithEmail(email: event.email, password: event.password);

    result.fold(
      (failure) => emit(AuthUnauthenticated(effect: ShowSnackBarEffect(message: failure.message))),
      (user)    => emit(AuthAuthenticated(user, effect: NavigateGoEffect(route: AppRoutes.home))),
    );
  }
}
```

### Side Effects

UI effects (navigation, snackbars) are emitted as part of state and consumed once:

```dart
// Effects live on state but are excluded from props (no rebuild)
class AuthState extends UiState with EffectClearable<AuthState> {
  @override
  List<Object?> get props => [status, user]; // effect NOT here
}

// In UI: EffectListener auto-reads and clears the effect
EffectListener<AuthBloc, AuthState>(
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) => ...,
  ),
)
```

---

## 🎨 Design System

Token-based design system for consistency across light and dark themes:

```dart
// Spacing tokens (AppSpacing)
SizedBox(height: AppSpacing.md);                        // 16px
Padding(padding: EdgeInsets.all(AppSpacing.lg));        // 24px

// Border radius tokens (AppRadius)
decoration: BoxDecoration(borderRadius: AppRadius.lgBorder);  // 12px

// Semantic color tokens (AppColorsExtension via context)
Container(color: context.appColors.success);            // theme-aware green
Container(color: context.appColors.subtleBackground);   // theme-aware muted bg

// Typography — always via textTheme
Text('Title', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
```

---

## 📈 Roadmap

- [x] **Phase 1**: Documentation & architecture design
- [x] **Phase 2**: Core infrastructure & project foundation
- [x] **Phase 3**: Auth, Home, Health features
- [x] **Phase 4**: Duel feature — full stack (domain, data, presentation, routing)
- [ ] **Phase 5**: Duel feature tests (unit + widget)
- [ ] **Phase 6**: Push notifications (lead change alerts, duel reminders)
- [ ] **Phase 7**: Share cards & social features
- [ ] **Phase 8**: Performance optimization & polish

---

## 📝 License

This project is for portfolio and learning purposes.

---

## 🙋‍♂️ Author

Built with ❤️ as a learning vehicle for mastering **Senior Flutter Engineering** concepts.

**Focus Areas:**
- Clean Architecture & SOLID principles
- Modular, scalable codebase design
- Production-grade error handling
- Platform-native health integrations
- Comprehensive testing strategies
