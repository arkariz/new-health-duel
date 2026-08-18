import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/router/routes.dart';
import 'package:health_duel/data/session/domain/domain.dart';
import 'package:health_duel/features/account/domain/usecases/delete_account.dart';
import 'package:health_duel/features/account/domain/usecases/requires_password_reauth.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_event.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_state.dart';
import 'package:health_duel/features/health/domain/usecases/usecases.dart';

part 'settings_side_effect.dart';

/// Settings BLoC — profile display, sign out, and permanent account
/// deletion (M2.4 in the MVP launch plan).
///
/// Uses [EffectBloc] pattern for one-shot side effects (ADR-004).
class SettingsBloc extends EffectBloc<SettingsEvent, SettingsState> {

  SettingsBloc({
    required SessionRepository sessionRepository,
    required SignOut signOut,
    required RequiresPasswordReauth requiresPasswordReauth,
    required DeleteAccount deleteAccount,
    required RevokeHealthPermissions revokeHealthPermissions,
  })  : _sessionRepository = sessionRepository,
        _signOut = signOut,
        _requiresPasswordReauth = requiresPasswordReauth,
        _deleteAccount = deleteAccount,
        _revokeHealthPermissions = revokeHealthPermissions,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsSignOutRequested>(_onSignOutRequested);
    on<SettingsDeleteAccountRequested>(_onDeleteAccountRequested);
  }
  
  final SessionRepository _sessionRepository;
  final SignOut _signOut;
  final RequiresPasswordReauth _requiresPasswordReauth;
  final DeleteAccount _deleteAccount;
  final RevokeHealthPermissions _revokeHealthPermissions;

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final userResult = await _sessionRepository.getCurrentUser();
    final reauthResult = await _requiresPasswordReauth();

    userResult.fold(
      (failure) => emit(SettingsError(failure.message)),
      (user) {
        if (user == null) {
          emit(const SettingsError('No signed-in user'));
          return;
        }
        emit(SettingsLoaded(
          user: user,
          requiresPasswordReauth: reauthResult.getOrElse(() => false),
        ));
      },
    );
  }

  Future<void> _onSignOutRequested(
    SettingsSignOutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(current.copyWith(isSigningOut: true));
    final result = await _signOut();

    result.fold(
      (failure) => emit(current.copyWith(
        isSigningOut: false,
        effect: _effectError(failure.message),
      )),
      (_) => emit(current.copyWith(
        isSigningOut: false,
        effect: _effectNavigateToLogin,
      )),
    );
  }

  Future<void> _onDeleteAccountRequested(
    SettingsDeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(current.copyWith(isDeleting: true));
    final result = await _deleteAccount(password: event.password);

    await result.fold(
      (failure) async {
        emit(current.copyWith(
          isDeleting: false,
          effect: _effectError(failure.message),
        ));
      },
      (_) async {
        // Best-effort: the account is already gone from Firebase either
        // way, so a Health Connect hiccup here shouldn't block the flow.
        await _revokeHealthPermissions();
        emit(current.copyWith(
          isDeleting: false,
          effect: _effectAccountDeleted,
        ));
      },
    );
  }
}
