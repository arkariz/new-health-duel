# Registry-based UiEffect & Flow-based State Machine Architecture

## 1. Metadata
- **Decision ID:** ADR-004
- **Date:** 2026-02-08
- **Roadmap Phase:** Phase 1 (Foundation & Core Architecture)
- **Status:** Accepted
- **Scope:** Global (affects all features using BLoC pattern)
- **Implementation:** `lib/core/bloc/`, `lib/core/presentation/widgets/effect_listener.dart`

---

## 2. Context (Why this decision exists)

### Current Problems

Health Duel uses `flutter_bloc` with feature-based Clean Architecture. To ensure
scalable, testable, and maintainable code, we need clear patterns for handling
side effects (navigation, dialogs, snackbars) separately from persistent state.

#### Problem 1: Side Effects Mixed with State
```dart
// ❌ Problem: Navigation, dialogs mixed into state
class DuelState {
  final bool shouldNavigate;  // Transient action, not state
  final String? dialogMessage;  // One-time message, not state
}
```

#### Problem 2: Unmanaged One-Shot Actions
- Navigation, dialogs, snackbars happen exactly once
- Developers forget to reset flags → duplicate triggers
- Side effects hard to test in isolation
- No guarantee effects fire exactly once

#### Problem 3: Scattered Effect Handling
```dart
// ❌ Current: Multiple scattered listeners
BlocListener<AuthBloc, AuthState>(...)
BlocListener<DuelBloc, DuelState>(...)
BlocListener<HealthBloc, HealthState>(...)
// ... scattered across widget tree
```

#### Problem 4: BLoC Coupled to Flutter UI
```dart
// ❌ Problem: Bloc depends on Flutter
class MyBloc {
  final GoRouter router;  // Violates Clean Architecture!

  void _onEvent(event, emit) {
    router.go('/next');  // Side effect in Bloc!
  }
}
```

### Constraints
- **Clean Architecture Compliance:** BLoC must not depend on Flutter widgets
- **Testability:** All side effects must be unit-testable
- **Team Scalability:** Consistent patterns for all features
- **Performance:** Minimize unnecessary UI rebuilds
- **Learning Goals:** Proper separation of concerns for Senior Engineer development

---

## 3. Decision

We adopt a **Registry-based UiEffect handling** pattern with these core principles:

### Core Principles

1. **Event → State → Effect Flow**
   - User action → Event → BLoC → State (+ optional Effect)
   - UI renders State, consumes Effect
   - Effect result → new Event (if needed)

2. **UiEffect is a One-Shot Message, Not State**
   - Excluded from Equatable props
   - Consumed exactly once
   - Auto-cleared after consumption

3. **Registry-based Effect Handling**
   - Type-safe mapping: Effect type → Handler function
   - Centralized, explicit registration
   - Throws if effect has no handler (fail-fast)

4. **BLoC Never Touches BuildContext**
   - BLoC emits Effects (data)
   - UI handles Effects (actions)
   - Clear separation of concerns

5. **Intent-based Dialogs (Not Callbacks)**
   - Dialog defined by `intentId`, not callbacks
   - User choice → Event with `DialogAction`
   - BLoC handles action, not UI

---

## 4. Options Considered

### 4.1 UiEffect Delivery Mechanism

**Option A — UiEffect as Property in State (Chosen)**
- Effect stored in state but excluded from `props`
- Listener uses manual comparison in `listenWhen`
- Cleared after consumption via event

**Option B — UiEffect via Separate Stream**
- BLoC exposes `Stream<UiEffect>` separate from state
- UI subscribes to stream
- Complex lifecycle management

**Option C — UiEffect in Props (Triggers Rebuild)**
- Effect included in `props`
- Every effect change triggers BlocBuilder
- Must use `buildWhen` everywhere

### 4.2 Effect Handler Pattern

**Option A — BlocListener Per Widget (Scattered)**
- Each widget handles its own effects
- Code duplication, scattered logic

**Option B — MultiBlocListener at Screen Level**
- Centralized per screen
- Still manual, repetitive

**Option C — Registry-based Handler (Chosen)**
- Type-safe effect → handler mapping
- One handler widget wraps entire screen
- Explicit, fail-fast if handler missing

---

## 5. Trade-offs Analysis (Critical Section)

### 5.1 UiEffect Delivery: State Property vs Stream

| Aspect | State Property (Chosen) | Separate Stream |
|--------|------------------------|-----------------|
| **Simplicity** | ✅ Single state object | ❌ Two subscriptions |
| **Testing** | ✅ bloc_test compatible | ⚠️ Need stream matchers |
| **Rebuild Control** | ⚠️ Must exclude from props | ✅ Automatic |
| **Memory Leaks** | ⚠️ Must clear effect | ⚠️ Must cancel subscription |
| **Team Adoption** | ✅ Familiar pattern | ❌ Learning curve |

**Decision:** State property wins for simplicity and familiarity. The trade-off
(exclude from props) is manageable with clear documentation.

---

### 5.2 Registry-based vs Scattered Listeners

| Aspect | Registry-based (Chosen) | Scattered Listeners |
|--------|------------------------|---------------------|
| **Consistency** | ✅ Single pattern | ❌ Varies by developer |
| **Discoverability** | ✅ All handlers in one place | ❌ Scattered in widgets |
| **Fail-Fast** | ✅ Throws if handler missing | ❌ Silent failure |
| **Setup Overhead** | ⚠️ Initial registry setup | ✅ No setup |
| **Flexibility** | ⚠️ Must register new effects | ✅ Ad-hoc handlers |

**Decision:** Registry-based wins for team consistency and fail-fast error handling.

---

### 5.3 Intent-based vs Callback-based Dialogs

| Aspect | Intent-based (Chosen) | Callback-based |
|--------|----------------------|----------------|
| **Testability** | ✅ Event-based, pure | ❌ Callbacks hard to test |
| **Serialization** | ✅ Intent is data | ❌ Callbacks not serializable |
| **Clean Architecture** | ✅ UI → Event → BLoC | ❌ Business in UI |
| **Simplicity** | ⚠️ More boilerplate | ✅ Quick callback |

**Decision:** Intent-based wins for testability and Clean Architecture compliance.

---

## 6. Consequences

### What Becomes Easier

- ✅ Testing side effects in isolation (pure BLoC tests)
- ✅ Onboarding new developers (consistent patterns)
- ✅ Debugging (centralized handlers, explicit registry)
- ✅ Adding new effects (register once, use everywhere)
- ✅ Maintaining Clean Architecture (BLoC never touches UI)

### What Becomes Harder

- ⚠️ Initial setup (registry, base classes)
- ⚠️ Simple features have more boilerplate
- ⚠️ Must remember to exclude effect from props
- ⚠️ Must clear effect after consumption

### Risks Accepted

**Risk 1: Over-engineering for Simple Cases**
- Small features may feel heavy with registry pattern

**Mitigation:**
- Use `BlocListener` with `listenWhen` directly for trivial cases
- Document when to use registry vs simple listener

**Risk 2: Registry Maintenance**
- New effects require registration

**Mitigation:**
- Fail-fast throws make missing handlers obvious
- Centralized registration in one file

**Risk 3: Learning Curve**
- Team must understand pattern

**Mitigation:**
- Clear documentation with examples
- Code templates for common patterns

---

## 7. Implementation Notes

### 7.1 Core Implementation

#### UiEffect Base Class
```dart
// lib/core/bloc/base/effect/ui_effect.dart
abstract class UiEffect extends Equatable {
  const UiEffect();

  String get effectId => '$runtimeType@${identityHashCode(this)}';

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [];
}
```

#### UiState Base Class
```dart
// lib/core/bloc/base/state/ui_state.dart
abstract class UiState extends Equatable {
  final UiEffect? effect;

  const UiState({this.effect});

  bool get hasEffect => effect != null;

  @override
  List<Object?> get props;  // Effect NOT included!
}

/// Mixin for effect manipulation in copyWith
mixin EffectClearable<T extends UiState> on UiState {
  T clearEffect();
  T withEffect(UiEffect? effect);
}
```

#### EffectBloc Base Class
```dart
// lib/core/bloc/base/effect_bloc.dart
abstract class EffectBloc<E, S extends UiState> extends Bloc<E, S> {
  EffectBloc(super.initialState);

  /// Emit state with side effect
  void emitWithEffect(Emitter<S> emit, S newState, UiEffect effect) {
    if (newState is EffectClearable) {
      emit((newState as EffectClearable).withEffect(effect) as S);
    } else {
      emit(newState);
    }
  }
}
```

#### EffectRegistry
```dart
// lib/core/bloc/effect/effect_registry.dart
typedef EffectHandler<T extends UiEffect> = void Function(
  BuildContext context,
  T effect,
);

class EffectRegistry {
  final Map<Type, EffectHandler<UiEffect>> _handlers = {};

  void register<T extends UiEffect>(EffectHandler<T> handler) {
    _handlers[T] = (context, effect) => handler(context, effect as T);
  }

  void handle(BuildContext context, UiEffect effect) {
    final handler = _handlers[effect.runtimeType];
    if (handler == null) {
      throw UnregisteredEffectError(effect);
    }
    handler(context, effect);
  }
}

final globalEffectRegistry = EffectRegistry();

class UnregisteredEffectError extends Error {
  final UiEffect effect;
  UnregisteredEffectError(this.effect);

  @override
  String toString() =>
      'No handler registered for effect: ${effect.runtimeType}';
}
```

#### EffectListener Widget
```dart
// lib/core/presentation/widgets/effect_listener.dart
class EffectListener<B extends BlocBase<S>, S extends UiState>
    extends StatelessWidget {
  final Widget child;
  final EffectRegistry? registry;

  const EffectListener({
    required this.child,
    this.registry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (prev, curr) =>
          curr.hasEffect && prev.effect != curr.effect,
      listener: (context, state) {
        final effect = state.effect;
        if (effect == null) return;

        (registry ?? globalEffectRegistry).handle(context, effect);
      },
      child: child,
    );
  }
}
```

### 7.2 Effect Taxonomy

#### Interface Markers
```dart
/// Marker: Effect auto-dismisses after duration
abstract interface class AutoDismissEffect {
  Duration get autoDismissDuration;
}

/// Marker: Effect requires user response (e.g., dialog)
abstract interface class InteractiveEffect {
  String get intentId;
}
```

#### Abstract Categories
```dart
abstract class NavigationEffect extends UiEffect {
  const NavigationEffect();
}

abstract class FeedbackEffect extends UiEffect implements AutoDismissEffect {
  const FeedbackEffect();
}
```

#### Concrete Effects

**Navigation Effects:**
```dart
// lib/core/bloc/effect/navigation/navigate_go_effect.dart
final class NavigateGoEffect extends NavigationEffect {
  final String route;
  final Object? arguments;

  const NavigateGoEffect(this.route, {this.arguments});

  @override
  List<Object?> get props => [route, arguments];
}

final class NavigatePushEffect extends NavigationEffect {
  final String route;
  final Object? arguments;

  const NavigatePushEffect(this.route, {this.arguments});

  @override
  List<Object?> get props => [route, arguments];
}

final class NavigatePopEffect extends NavigationEffect {
  final Object? result;

  const NavigatePopEffect({this.result});

  @override
  List<Object?> get props => [result];
}
```

**Feedback Effects:**
```dart
// lib/core/bloc/effect/snackbar/snackbar_effect.dart
enum FeedbackSeverity { info, success, warning, error }

final class ShowSnackBarEffect extends FeedbackEffect {
  final String message;
  final FeedbackSeverity severity;
  final String? actionLabel;
  final String? actionIntentId;

  @override
  final Duration autoDismissDuration;

  const ShowSnackBarEffect({
    required this.message,
    this.severity = FeedbackSeverity.info,
    this.actionLabel,
    this.actionIntentId,
    this.autoDismissDuration = const Duration(seconds: 4),
  });

  @override
  List<Object?> get props =>
      [message, severity, actionLabel, actionIntentId, autoDismissDuration];
}
```

**Dialog Effects:**
```dart
// lib/core/bloc/effect/dialog/dialog_effect.dart
enum DialogAction {
  confirm,
  cancel,
  destructive,
  custom,
}

enum DialogIcon {
  info,
  success,
  warning,
  error,
}

class DialogActionConfig extends Equatable {
  final DialogAction action;
  final String? label;
  final bool isPrimary;

  const DialogActionConfig({
    required this.action,
    this.label,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [action, label, isPrimary];
}

final class ShowDialogEffect extends UiEffect implements InteractiveEffect {
  @override
  final String intentId;
  final String title;
  final String message;
  final List<DialogActionConfig> actions;
  final bool isDismissible;
  final DialogIcon? icon;
  final bool isFullScreen;

  const ShowDialogEffect({
    required this.intentId,
    required this.title,
    required this.message,
    this.actions = const [],
    this.isDismissible = true,
    this.icon,
    this.isFullScreen = false,
  });

  @override
  List<Object?> get props =>
      [intentId, title, message, actions, isDismissible, icon, isFullScreen];
}
```

### 7.3 Effect Registration

```dart
// lib/core/bloc/effect/effect_handlers.dart
import 'package:go_router/go_router.dart';

void setupEffectHandlers({EffectRegistry? registry}) {
  final effectRegistry = registry ?? globalEffectRegistry;

  effectRegistry
    // Navigation effects
    ..register<NavigateGoEffect>((context, effect) {
      context.go(effect.route, extra: effect.arguments);
    })
    ..register<NavigatePushEffect>((context, effect) {
      context.push(effect.route, extra: effect.arguments);
    })
    ..register<NavigatePopEffect>((context, effect) {
      if (context.canPop()) {
        context.pop(effect.result);
      }
    })
    // Snackbar effects
    ..register<ShowSnackBarEffect>((context, effect) {
      final colorScheme = Theme.of(context).colorScheme;
      final color = switch (effect.severity) {
        FeedbackSeverity.info => colorScheme.primary,
        FeedbackSeverity.success => Colors.green,
        FeedbackSeverity.warning => Colors.orange,
        FeedbackSeverity.error => colorScheme.error,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(effect.message),
          backgroundColor: color,
          duration: effect.autoDismissDuration,
          action: effect.actionLabel != null
              ? SnackBarAction(
                  label: effect.actionLabel!,
                  onPressed: () {
                    // Emit event with action intent ID
                  },
                )
              : null,
        ),
      );
    })
    // Dialog effects
    ..register<ShowDialogEffect>((context, effect) {
      if (effect.isFullScreen) {
        showDialog<DialogAction>(
          context: context,
          barrierDismissible: effect.isDismissible,
          builder: (ctx) => Dialog.fullscreen(
            child: _buildDialogContent(effect),
          ),
        );
      } else {
        showDialog<DialogAction>(
          context: context,
          barrierDismissible: effect.isDismissible,
          builder: (ctx) => AlertDialog(
            title: Text(effect.title),
            content: Text(effect.message),
            icon: effect.icon != null ? _buildDialogIcon(effect.icon!) : null,
            actions: effect.actions
                .map((config) => _buildDialogButton(config))
                .toList(),
          ),
        );
      }
    });
}

Widget _buildDialogContent(ShowDialogEffect effect) {
  // Implementation for fullscreen dialog content
  // ...
}

Widget _buildDialogIcon(DialogIcon icon) {
  // Implementation for dialog icon widget
  // ...
}

Widget _buildDialogButton(DialogActionConfig config) {
  // Implementation for dialog action button
  // ...
}
```

Call in `main.dart`:
```dart
void main() {
  setupEffectHandlers();
  runApp(const HealthDuelApp());
}
```

### 7.4 Feature Implementation Example

#### Duel BLoC State
```dart
// lib/features/duel/presentation/bloc/duel_state.dart
part of 'duel_bloc.dart';

sealed class DuelState extends UiState with EffectClearable<DuelState> {
  final DuelStatus status;
  final Duel? currentDuel;
  final String? errorMessage;

  const DuelState({
    required this.status,
    this.currentDuel,
    this.errorMessage,
    super.effect,
  });

  @override
  List<Object?> get props => [status, currentDuel, errorMessage];
  // Note: effect NOT in props!

  @override
  DuelState clearEffect() => copyWith(effect: null);

  @override
  DuelState withEffect(UiEffect? effect) => copyWith(effect: effect);

  DuelState copyWith({
    DuelStatus? status,
    Duel? currentDuel,
    String? errorMessage,
    UiEffect? effect,
  });
}

final class DuelInitial extends DuelState {
  const DuelInitial() : super(status: DuelStatus.initial);

  @override
  DuelState copyWith({
    DuelStatus? status,
    Duel? currentDuel,
    String? errorMessage,
    UiEffect? effect,
  }) {
    return DuelLoaded(
      status: status ?? this.status,
      currentDuel: currentDuel ?? this.currentDuel,
      errorMessage: errorMessage,
      effect: effect,
    );
  }
}

final class DuelLoaded extends DuelState {
  const DuelLoaded({
    required super.status,
    super.currentDuel,
    super.errorMessage,
    super.effect,
  });

  @override
  DuelState copyWith({
    DuelStatus? status,
    Duel? currentDuel,
    String? errorMessage,
    UiEffect? effect,
  }) {
    return DuelLoaded(
      status: status ?? this.status,
      currentDuel: currentDuel ?? this.currentDuel,
      errorMessage: errorMessage,
      effect: effect,
    );
  }
}
```

#### Duel BLoC Events
```dart
// lib/features/duel/presentation/bloc/duel_event.dart
sealed class DuelEvent extends Equatable {}

final class LoadDuel extends DuelEvent {
  final String duelId;
  LoadDuel(this.duelId);
  @override
  List<Object> get props => [duelId];
}

final class AcceptDuel extends DuelEvent {
  final String duelId;
  AcceptDuel(this.duelId);
  @override
  List<Object> get props => [duelId];
}

final class DeleteDuel extends DuelEvent {
  final String duelId;
  DeleteDuel(this.duelId);
  @override
  List<Object> get props => [duelId];
}

final class DialogActionSelected extends DuelEvent {
  final String intentId;
  final DialogAction action;

  const DialogActionSelected(this.intentId, this.action);

  @override
  List<Object> get props => [intentId, action];
}
```

#### Duel BLoC Implementation
```dart
// lib/features/duel/presentation/bloc/duel_bloc.dart
part 'duel_event.dart';
part 'duel_state.dart';
part 'duel_side_effect.dart';

class DuelBloc extends EffectBloc<DuelEvent, DuelState> {
  final GetDuelById _getDuelById;
  final AcceptDuelUseCase _acceptDuel;
  final DeleteDuelUseCase _deleteDuel;

  DuelBloc({
    required GetDuelById getDuelById,
    required AcceptDuelUseCase acceptDuel,
    required DeleteDuelUseCase deleteDuel,
  })  : _getDuelById = getDuelById,
        _acceptDuel = acceptDuel,
        _deleteDuel = deleteDuel,
        super(const DuelInitial()) {
    on<LoadDuel>(_onLoadDuel);
    on<AcceptDuel>(_onAcceptDuel);
    on<DeleteDuel>(_onDeleteDuel);
    on<DialogActionSelected>(_onDialogActionSelected);
  }

  Future<void> _onLoadDuel(LoadDuel event, Emitter<DuelState> emit) async {
    emit(state.copyWith(status: DuelStatus.loading));

    final result = await _getDuelById(event.duelId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: DuelStatus.error,
        errorMessage: failure.message,
        effect: _effectErrorSnackbar(failure.message),
      )),
      (duel) => emit(state.copyWith(
        status: DuelStatus.loaded,
        currentDuel: duel,
      )),
    );
  }

  Future<void> _onAcceptDuel(AcceptDuel event, Emitter<DuelState> emit) async {
    final result = await _acceptDuel(event.duelId);

    result.fold(
      (failure) => emit(state.copyWith(
        effect: _effectErrorSnackbar(failure.message),
      )),
      (duel) => emit(state.copyWith(
        currentDuel: duel,
        effect: _effectDuelAcceptedSnackbar,
      )),
    );
  }

  Future<void> _onDeleteDuel(DeleteDuel event, Emitter<DuelState> emit) async {
    // Show confirmation dialog via effect
    emit(state.copyWith(
      effect: _effectDeleteConfirmationDialog(event.duelId),
    ));
  }

  Future<void> _onDialogActionSelected(
    DialogActionSelected event,
    Emitter<DuelState> emit,
  ) async {
    // Handle dialog action based on intentId
    if (event.intentId.startsWith('delete_duel_')) {
      if (event.action == DialogAction.confirm) {
        final duelId = event.intentId.replaceFirst('delete_duel_', '');
        final result = await _deleteDuel(duelId);

        result.fold(
          (failure) => emit(state.copyWith(
            effect: _effectErrorSnackbar(failure.message),
          )),
          (_) => emit(state.copyWith(
            status: DuelStatus.deleted,
            effect: const NavigatePopEffect(),
          )),
        );
      }
    }
  }
}
```

#### Duel Side Effects
```dart
// lib/features/duel/presentation/bloc/duel_side_effect.dart
part of 'duel_bloc.dart';

extension DuelSideEffect on DuelBloc {
  // ════════════════════════════════════════════
  // DIALOG EFFECTS
  // ════════════════════════════════════════════

  ShowDialogEffect _effectDeleteConfirmationDialog(String duelId) =>
      ShowDialogEffect(
        intentId: 'delete_duel_$duelId',
        title: 'Delete Duel?',
        message: 'Are you sure you want to delete this duel? This action cannot be undone.',
        icon: DialogIcon.warning,
        actions: const [
          DialogActionConfig(
            action: DialogAction.cancel,
            label: 'Cancel',
          ),
          DialogActionConfig(
            action: DialogAction.destructive,
            label: 'Delete',
            isPrimary: true,
          ),
        ],
      );

  // ════════════════════════════════════════════
  // SNACKBAR EFFECTS
  // ════════════════════════════════════════════

  ShowSnackBarEffect _effectErrorSnackbar(String message) =>
      ShowSnackBarEffect(
        message: message,
        severity: FeedbackSeverity.error,
      );

  ShowSnackBarEffect get _effectDuelAcceptedSnackbar => const ShowSnackBarEffect(
        message: 'Duel accepted! Let the competition begin.',
        severity: FeedbackSeverity.success,
      );
}
```

#### Screen Implementation
```dart
// lib/features/duel/presentation/screens/duel_details_screen.dart
class DuelDetailsScreen extends StatelessWidget {
  final String duelId;

  const DuelDetailsScreen({required this.duelId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DuelBloc>()..add(LoadDuel(duelId)),
      child: EffectListener<DuelBloc, DuelState>(
        child: Scaffold(
          appBar: AppBar(title: const Text('Duel Details')),
          body: BlocBuilder<DuelBloc, DuelState>(
            builder: (context, state) {
              if (state.status == DuelStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == DuelStatus.error) {
                return Center(child: Text('Error: ${state.errorMessage}'));
              }

              final duel = state.currentDuel;
              if (duel == null) {
                return const Center(child: Text('No duel found'));
              }

              return _DuelDetailsContent(duel: duel);
            },
          ),
        ),
      ),
    );
  }
}
```

### 7.5 Anti-patterns to Avoid

```dart
// ❌ FORBIDDEN: Callback in effect
ShowDialogEffect(
  onConfirm: () => doSomething(),  // NO! Not testable
)

// ✅ CORRECT: Intent-based
ShowDialogEffect(
  intentId: 'confirm_delete',
  actions: [DialogAction.confirm, DialogAction.cancel],
)
// UI: User taps confirm → Event(DialogActionSelected('confirm_delete', confirm))
// BLoC: Handles event, transitions state
```

```dart
// ❌ FORBIDDEN: Navigation in BLoC
class MyBloc extends Bloc<E, S> {
  final GoRouter router;  // NO! BLoC depends on Flutter

  void _onEvent(event, emit) {
    router.go('/next');  // NO! Side effect in BLoC
  }
}

// ✅ CORRECT: Effect emission
void _onEvent(event, emit) {
  emit(state.copyWith(effect: NavigateGoEffect('/next')));
}
// UI handles the actual navigation
```

```dart
// ❌ FORBIDDEN: Effect in Equatable props
@override
List<Object?> get props => [status, data, effect];  // NO! Causes rebuilds

// ✅ CORRECT: Exclude effect
@override
List<Object?> get props => [status, data];  // Effect NOT included
```

```dart
// ❌ FORBIDDEN: Multiple effects without state transition
emit(state.copyWith(effect: EffectA()));
emit(state.copyWith(effect: EffectB()));  // EffectA may be lost!

// ✅ CORRECT: Chain via state transitions
emit(state.copyWith(status: loading, effect: ShowLoading()));
// ... async work ...
emit(state.copyWith(status: success, effect: NavigateToNext()));
```

### 7.6 Boundaries to Maintain

| Layer | Can Use | Cannot Use |
|-------|---------|------------|
| **BLoC** | UiEffect, UiState, Events | GoRouter, BuildContext, Widgets |
| **UI** | EffectListener, Registry | Business logic, API calls |
| **Effect Handler** | BuildContext, Router | Business logic, State mutation |

### 7.7 Testing Strategy

#### Unit Testing Effect Emission
```dart
blocTest<DuelBloc, DuelState>(
  'emits NavigatePopEffect on successful delete',
  build: () => DuelBloc(
    getDuelById: mockGetDuel,
    acceptDuel: mockAccept,
    deleteDuel: mockDelete,
  ),
  act: (bloc) async {
    bloc.add(DeleteDuel('123'));
    await Future.delayed(Duration.zero);
    bloc.add(const DialogActionSelected('delete_duel_123', DialogAction.confirm));
  },
  expect: () => [
    // Delete confirmation dialog shown
    isA<DuelState>()
        .having((s) => s.effect, 'effect', isA<ShowDialogEffect>()),
    // After confirmation, duel deleted and navigation effect emitted
    isA<DuelState>()
        .having((s) => s.status, 'status', DuelStatus.deleted)
        .having((s) => s.effect, 'effect', isA<NavigatePopEffect>()),
  ],
);
```

## 8. Revisit Criteria

This decision should be re-evaluated when:

1. **Effect Complexity Explodes:** > 20 effect types (consider categorization)
2. **Stream-based Needed:** Effects need buffering/debouncing
3. **Team Feedback:** Developers consistently struggle with pattern
4. **Performance Issues:** `listenWhen` comparisons become bottleneck
5. **Framework Changes:** `flutter_bloc` introduces native effect support

## 9. Related Artifacts

### Documentation
- [Architecture Overview](../ARCHITECTURE_OVERVIEW.md) - BLoC pattern details
- [Architecture Vision](../../00-foundation/ARCHITECTURE_VISION.md) - Design principles
- [Contributing Guidelines](../../CONTRIBUTING.md) - BLoC coding standards

### Code References
- `lib/core/bloc/` - Effect BLoC implementation
- `lib/core/presentation/widgets/effect_listener.dart` - Listener widget
- `lib/features/*/presentation/bloc/*_side_effect.dart` - Feature side effects

### Related ADRs
- [ADR-002: Exception Isolation Strategy](0002-exception-isolation-strategy.md) - Pattern inspiration

---

**Decision Author:** Health Duel Team
**Reviewed By:** Team Lead, Coder-Docs
**Approved Date:** 2026-02-08
**Implementation Status:** Accepted for Phase 1, pattern established from reference project
**Reference Implementation:** `reference_project/fintrack_lite/`
