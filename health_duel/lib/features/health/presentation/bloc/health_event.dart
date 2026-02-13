import 'package:equatable/equatable.dart';

/// Health Events - User actions for step counting feature
sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize health feature and check permissions
class HealthInitRequested extends HealthEvent {
  const HealthInitRequested();
}

/// Request health data permissions from user
class HealthPermissionRequested extends HealthEvent {
  const HealthPermissionRequested();
}

/// Refresh step count data (manual pull-to-refresh)
class HealthRefreshRequested extends HealthEvent {
  const HealthRefreshRequested();
}

/// Revoke health permissions (for debugging/testing)
class HealthRevokeRequested extends HealthEvent {
  const HealthRevokeRequested();
}
