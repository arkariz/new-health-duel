/// Test fixtures for consistent test data
///
/// Provides reusable test objects for unit and widget tests.
library;

import 'package:health_duel/data/session/data/models/user_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// User Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Standard test user model (DTO)
final tUserModel = UserModel(
  id: 'test-user-123',
  name: 'Test User',
  email: 'test@email.com',
  photoUrl: 'https://example.com/photo.jpg',
  createdAt: DateTime(2025, 1, 1),
);

/// User without photo
final tUserNoPhoto = UserModel(
  id: 'test-user-456',
  name: 'No Photo User',
  email: 'nophoto@example.com',
  photoUrl: null,
  createdAt: DateTime(2025, 1, 1),
);

/// User with empty name (fallback to email)
final tUserNoName = UserModel(
  id: 'test-user-789',
  name: '',
  email: 'noname@example.com',
  photoUrl: null,
  createdAt: DateTime(2025, 1, 1),
);

// ═══════════════════════════════════════════════════════════════════════════
// Auth Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Valid test email
const tEmail = 'test@email.com';

/// Valid test password
const tPassword = 'TestPassword123!';

/// Invalid test email
const tInvalidEmail = 'not-an-email';

/// Weak test password
const tWeakPassword = '123';

/// Test user name
const tName = 'Test User';

// ═══════════════════════════════════════════════════════════════════════════
// Error Fixtures
// ═══════════════════════════════════════════════════════════════════════════

/// Standard error message
const tErrorMessage = 'Something went wrong';

/// Network error message
const tNetworkErrorMessage = 'No internet connection';

/// Auth error message
const tAuthErrorMessage = 'Invalid email or password';
