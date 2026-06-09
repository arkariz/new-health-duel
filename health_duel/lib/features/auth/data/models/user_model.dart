/// Auth User Model Re-export
///
/// Re-exports the global [UserModel] for auth feature usage.
/// This ensures consistency and avoids duplication.
///
/// The global User model is defined in lib/data/session/data/models/user_model.dart
library;

import 'package:health_duel/data/session/data/data.dart' show UserModel;
import 'package:health_duel/data/session/data/models/user_model.dart' show UserModel;
import 'package:health_duel/data/session/session.dart' show UserModel;
import 'package:health_duel/features/auth/auth.dart' show UserModel;
import 'package:health_duel/features/auth/data/models/user_model.dart' show UserModel;

export 'package:health_duel/data/session/data/models/user_model.dart';
