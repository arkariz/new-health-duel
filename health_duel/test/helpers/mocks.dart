/// Mock factories for testing
///
/// Uses mocktail for type-safe mocking.
/// Register fallback values in setUpAll().
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/core/presentation/widgets/connectivity/connectivity.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:health_duel/features/duel/data/datasources/duel_firestore_datasource.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/domain/repositories/duel_repository.dart';
import 'package:health_duel/features/duel/domain/usecases/accept_duel.dart';
import 'package:health_duel/features/duel/domain/usecases/create_duel.dart';
import 'package:health_duel/features/duel/domain/usecases/decline_duel.dart';
import 'package:health_duel/features/duel/domain/usecases/get_active_duels.dart';
import 'package:health_duel/features/duel/domain/usecases/get_duel_history.dart';
import 'package:health_duel/features/duel/domain/usecases/get_opponents.dart';
import 'package:health_duel/features/duel/domain/usecases/get_pending_duels.dart';
import 'package:health_duel/features/duel/domain/usecases/sync_health_data.dart';
import 'package:health_duel/features/duel/domain/usecases/update_step_count.dart';
import 'package:health_duel/features/duel/domain/usecases/watch_duel.dart';
import 'package:health_duel/features/duel/domain/value_objects/step_count.dart'
    as duel;
import 'package:health_duel/features/duel/presentation/bloc/create_duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/create_duel_state.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_event.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_state.dart';
import 'package:health_duel/features/health/domain/repositories/health_repository.dart';
import 'package:mocktail/mocktail.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Auth Feature Mocks
// ═══════════════════════════════════════════════════════════════════════════

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockRegisterWithEmail extends Mock implements RegisterWithEmail {}

class MockSignOut extends Mock implements SignOut {}

/// Mock AuthBloc for widget testing
///
/// Usage:
/// ```dart
/// late MockAuthBloc mockAuthBloc;
///
/// setUp(() {
///   mockAuthBloc = MockAuthBloc();
/// });
///
/// // Stub state and stream
/// whenListen(
///   mockAuthBloc,
///   Stream<AuthState>.fromIterable([AuthLoading(), AuthAuthenticated(user)]),
///   initialState: AuthInitial(),
/// );
/// ```
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// Mock ConnectivityCubit for widget testing
class MockConnectivityCubit extends MockCubit<ConnectivityStatus>
    implements ConnectivityCubit {}

// ═══════════════════════════════════════════════════════════════════════════
// Fallback Values
// ═══════════════════════════════════════════════════════════════════════════

/// Register fallback values for mocktail
///
/// Call this in setUpAll() before using any mocks:
/// ```dart
/// setUpAll(() {
///   registerFallbackValues();
/// });
/// ```
void registerFallbackValues() {
  // Auth
  registerFallbackValue(Right<Failure, UserModel>(FakeUserModel()));
  registerFallbackValue(const Right<Failure, UserModel?>(null));
  registerFallbackValue(const Right<Failure, void>(null));
  registerFallbackValue(
    const Left<Failure, UserModel>(AuthFailure(message: 'test')),
  );

  // Auth Events
  registerFallbackValue(const AuthCheckRequested());
  registerFallbackValue(
    const AuthSignInWithEmailRequested(email: '', password: ''),
  );
  registerFallbackValue(const AuthSignInWithGoogleRequested());
  registerFallbackValue(const AuthSignOutRequested());

  // Auth States
  registerFallbackValue(const AuthInitial());

  // Duel
  registerFallbackValue(FakeDuel());
  registerFallbackValue(FakeDuelStepCount());
  registerFallbackValue(const Right<Failure, List<Duel>>([]));
  registerFallbackValue(const Left<Failure, List<Duel>>(ServerFailure(message: 'test')));
  registerFallbackValue(const Right<Failure, Duel?>(null));
}

/// Fake UserModel for fallback registration
class FakeUserModel extends Fake implements UserModel {}

// ═══════════════════════════════════════════════════════════════════════════
// Auth Mock Setup Helpers
// ═══════════════════════════════════════════════════════════════════════════

extension MockAuthRepositoryX on MockAuthRepository {
  /// Setup auth state stream with provided controller
  void setupAuthStateChanges(StreamController<UserModel?> controller) {
    when(authStateChanges).thenAnswer((_) => controller.stream);
  }
}

extension MockSessionRepositoryX on MockSessionRepository {
  void setupGetCurrentUser(UserModel? userModel) {
    when(getCurrentUser).thenAnswer((_) async => Right(userModel));
  }

  void setupFailure(Failure failure) {
    when(getCurrentUser).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithEmailX on MockSignInWithEmail {
  /// Setup successful sign in
  void setupSuccess(UserModel user) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Right(user));
  }

  /// Setup failed sign in
  void setupFailure(Failure failure) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithGoogleX on MockSignInWithGoogle {
  void setupSuccess(UserModel user) {
    when(call).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(call).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithAppleX on MockSignInWithApple {
  void setupSuccess(UserModel user) {
    when(call).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(call).thenAnswer((_) async => Left(failure));
  }
}

extension MockRegisterWithEmailX on MockRegisterWithEmail {
  void setupSuccess(UserModel user) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignOutX on MockSignOut {
  void setupSuccess() {
    when(call).thenAnswer((_) async => const Right(null));
  }

  void setupFailure(Failure failure) {
    when(call).thenAnswer((_) async => Left(failure));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Duel Feature Mocks
// ═══════════════════════════════════════════════════════════════════════════

class MockDuelRepository extends Mock implements DuelRepository {}

class MockDuelFirestoreDataSource extends Mock
    implements DuelFirestoreDataSource {}

class MockHealthRepository extends Mock implements HealthRepository {}

// Use-case mocks
class MockGetActiveDuels extends Mock implements GetActiveDuels {}

class MockGetPendingDuels extends Mock implements GetPendingDuels {}

class MockGetDuelHistory extends Mock implements GetDuelHistory {}

class MockAcceptDuel extends Mock implements AcceptDuel {}

class MockDeclineDuel extends Mock implements DeclineDuel {}

class MockGetOpponents extends Mock implements GetOpponents {}

class MockCreateDuel extends Mock implements CreateDuel {}

class MockWatchDuel extends Mock implements WatchDuel {}

class MockSyncHealthData extends Mock implements SyncHealthData {}

class MockUpdateStepCount extends Mock implements UpdateStepCount {}

/// Mock DuelListBloc for widget testing
class MockDuelListBloc extends MockBloc<DuelListEvent, DuelListState>
    implements DuelListBloc {}

/// Mock CreateDuelBloc for widget testing
class MockCreateDuelBloc extends MockBloc<CreateDuelEvent, CreateDuelState>
    implements CreateDuelBloc {}

/// Mock DuelBloc for widget testing
class MockDuelBloc extends MockBloc<DuelEvent, DuelState>
    implements DuelBloc {}

// ═══════════════════════════════════════════════════════════════════════════
// Duel Fake Types
// ═══════════════════════════════════════════════════════════════════════════

class FakeDuel extends Fake implements Duel {}

class FakeDuelStepCount extends Fake implements duel.StepCount {}

// ═══════════════════════════════════════════════════════════════════════════
// Duel Mock Setup Extensions
// ═══════════════════════════════════════════════════════════════════════════

extension MockDuelRepositoryX on MockDuelRepository {
  void setupGetActiveDuels(String userId, List<Duel> duels) {
    when(() => getActiveDuels(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupGetActiveDuelsFailure(String userId, Failure failure) {
    when(() => getActiveDuels(userId)).thenAnswer((_) async => Left(failure));
  }

  void setupGetPendingDuels(String userId, List<Duel> duels) {
    when(() => getPendingDuels(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupGetPendingDuelsFailure(String userId, Failure failure) {
    when(() => getPendingDuels(userId))
        .thenAnswer((_) async => Left(failure));
  }

  void setupGetDuelHistory(String userId, List<Duel> duels) {
    when(() => getDuelHistory(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupGetDuelHistoryFailure(String userId, Failure failure) {
    when(() => getDuelHistory(userId)).thenAnswer((_) async => Left(failure));
  }

  void setupGetDuelById(String duelId, Duel duel) {
    when(() => getDuelById(duelId)).thenAnswer((_) async => Right(duel));
  }

  void setupGetDuelByIdFailure(String duelId, Failure failure) {
    when(() => getDuelById(duelId)).thenAnswer((_) async => Left(failure));
  }

  void setupAcceptDuel(String duelId, Duel duel) {
    when(() => acceptDuel(duelId)).thenAnswer((_) async => Right(duel));
  }

  void setupAcceptDuelFailure(String duelId, Failure failure) {
    when(() => acceptDuel(duelId)).thenAnswer((_) async => Left(failure));
  }

  void setupCancelDuel(String duelId) {
    when(() => cancelDuel(duelId))
        .thenAnswer((_) async => const Right(null));
  }

  void setupCancelDuelFailure(String duelId, Failure failure) {
    when(() => cancelDuel(duelId)).thenAnswer((_) async => Left(failure));
  }

  void setupCreateDuel({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    required Duel duel,
  }) {
    when(
      () => createDuel(
        challengerId: challengerId,
        challengedId: challengedId,
        challengerName: challengerName,
        challengedName: challengedName,
      ),
    ).thenAnswer((_) async => Right(duel));
  }

  void setupCreateDuelFailure({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    required Failure failure,
  }) {
    when(
      () => createDuel(
        challengerId: challengerId,
        challengedId: challengedId,
        challengerName: challengerName,
        challengedName: challengedName,
      ),
    ).thenAnswer((_) async => Left(failure));
  }

  void setupGetActiveDuelBetween(
    String userId1,
    String userId2,
    Duel? duel,
  ) {
    when(() => getActiveDuelBetween(userId1, userId2))
        .thenAnswer((_) async => Right(duel));
  }

  void setupGetActiveDuelBetweenFailure(
    String userId1,
    String userId2,
    Failure failure,
  ) {
    when(() => getActiveDuelBetween(userId1, userId2))
        .thenAnswer((_) async => Left(failure));
  }

  void setupGetOpponents(String excludeUserId, List<UserModel> opponents) {
    when(() => getOpponents(excludeUserId))
        .thenAnswer((_) async => Right(opponents));
  }

  void setupGetOpponentsFailure(String excludeUserId, Failure failure) {
    when(() => getOpponents(excludeUserId))
        .thenAnswer((_) async => Left(failure));
  }

  void setupUpdateStepCount({
    required String duelId,
    required String userId,
    required duel.StepCount steps,
    required Duel result,
  }) {
    when(
      () => updateStepCount(
        duelId: duelId,
        userId: userId,
        steps: steps,
      ),
    ).thenAnswer((_) async => Right(result));
  }

  void setupUpdateStepCountFailure({
    required String duelId,
    required String userId,
    required duel.StepCount steps,
    required Failure failure,
  }) {
    when(
      () => updateStepCount(
        duelId: duelId,
        userId: userId,
        steps: steps,
      ),
    ).thenAnswer((_) async => Left(failure));
  }

  void setupWatchDuel(String duelId, Stream<Either<Failure, Duel>> stream) {
    when(() => watchDuel(duelId)).thenAnswer((_) => stream);
  }
}

extension MockGetActiveDuelsX on MockGetActiveDuels {
  void setupSuccess(String userId, List<Duel> duels) {
    when(() => call(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupFailure(String userId, Failure failure) {
    when(() => call(userId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockGetPendingDuelsX on MockGetPendingDuels {
  void setupSuccess(String userId, List<Duel> duels) {
    when(() => call(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupFailure(String userId, Failure failure) {
    when(() => call(userId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockGetDuelHistoryX on MockGetDuelHistory {
  void setupSuccess(String userId, List<Duel> duels) {
    when(() => call(userId)).thenAnswer((_) async => Right(duels));
  }

  void setupFailure(String userId, Failure failure) {
    when(() => call(userId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockAcceptDuelX on MockAcceptDuel {
  void setupSuccess(String duelId, Duel duel) {
    when(() => call(duelId)).thenAnswer((_) async => Right(duel));
  }

  void setupFailure(String duelId, Failure failure) {
    when(() => call(duelId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockDeclineDuelX on MockDeclineDuel {
  void setupSuccess(String duelId) {
    when(() => call(duelId)).thenAnswer((_) async => const Right(null));
  }

  void setupFailure(String duelId, Failure failure) {
    when(() => call(duelId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockGetOpponentsX on MockGetOpponents {
  void setupSuccess(String excludeUserId, List<UserModel> opponents) {
    when(() => call(excludeUserId)).thenAnswer((_) async => Right(opponents));
  }

  void setupFailure(String excludeUserId, Failure failure) {
    when(() => call(excludeUserId)).thenAnswer((_) async => Left(failure));
  }
}

extension MockCreateDuelX on MockCreateDuel {
  void setupSuccess({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    required Duel result,
  }) {
    when(
      () => call(
        challengerId: challengerId,
        challengedId: challengedId,
        challengerName: challengerName,
        challengedName: challengedName,
      ),
    ).thenAnswer((_) async => Right(result));
  }

  void setupFailure({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    required Failure failure,
  }) {
    when(
      () => call(
        challengerId: challengerId,
        challengedId: challengedId,
        challengerName: challengerName,
        challengedName: challengedName,
      ),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSyncHealthDataX on MockSyncHealthData {
  void setupSuccess({
    required String duelId,
    required String userId,
    required Duel result,
  }) {
    when(
      () => call(duelId: duelId, userId: userId),
    ).thenAnswer((_) async => Right(result));
  }

  void setupFailure({
    required String duelId,
    required String userId,
    required Failure failure,
  }) {
    when(
      () => call(duelId: duelId, userId: userId),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockWatchDuelX on MockWatchDuel {
  void setupStream(String duelId, Stream<Either<Failure, Duel>> stream) {
    when(() => call(duelId)).thenAnswer((_) => stream);
  }

  void setupEmptyStream(String duelId) {
    when(() => call(duelId)).thenAnswer((_) => const Stream.empty());
  }
}

extension MockUpdateStepCountX on MockUpdateStepCount {
  void setupSuccess({
    required String duelId,
    required String userId,
    required duel.StepCount steps,
    required Duel result,
  }) {
    when(
      () => call(duelId: duelId, userId: userId, steps: steps),
    ).thenAnswer((_) async => Right(result));
  }

  void setupFailure({
    required String duelId,
    required String userId,
    required duel.StepCount steps,
    required Failure failure,
  }) {
    when(
      () => call(duelId: duelId, userId: userId, steps: steps),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSessionRepositoryDuelX on MockSessionRepository {
  void setupGetCurrentUserDuel(UserModel? user) {
    when(getCurrentUser).thenAnswer((_) async => Right(user));
  }
}
