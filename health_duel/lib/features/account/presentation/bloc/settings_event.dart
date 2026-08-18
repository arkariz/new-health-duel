import 'package:equatable/equatable.dart';
import 'package:health_duel/features/account/account.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current user + whether account deletion needs a password.
class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

/// Sign out of the current session.
class SettingsSignOutRequested extends SettingsEvent {
  const SettingsSignOutRequested();
}

/// Permanently delete the account. [password] is required for
/// email/password accounts (see [SettingsLoaded.requiresPasswordReauth]);
/// leave null for Google accounts, which re-authenticate via a native
/// prompt instead.
class SettingsDeleteAccountRequested extends SettingsEvent {
  const SettingsDeleteAccountRequested({this.password});
  final String? password;

  @override
  List<Object?> get props => [password];
}
