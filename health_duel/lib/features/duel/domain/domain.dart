/// Duel Feature Domain Layer
///
/// Contains all domain entities, value objects, repositories, and use cases.
library;

// Entities
export 'entities/duel.dart';

// Value Objects
export 'value_objects/value_objects.dart';

// Repositories
export 'repositories/duel_repository.dart';

// Use Cases
export 'usecases/accept_duel.dart';
export 'usecases/create_duel.dart';
export 'usecases/decline_duel.dart';
export 'usecases/get_active_duels.dart';
export 'usecases/get_duel_history.dart';
export 'usecases/get_pending_duels.dart';
export 'usecases/sync_health_data.dart';
export 'usecases/update_step_count.dart';
export 'usecases/watch_duel.dart';
