import 'package:shared_preferences/shared_preferences.dart';

/// Pointer to the duel currently being watched, so the background sync
/// isolate (which has no access to Firestore "active duels" queries or the
/// app's GetIt container) knows which duel/user to sync without a network
/// round-trip.
///
/// Set by `DuelBloc` when it starts watching an active duel, cleared when
/// that duel completes. Duel/user IDs are not sensitive, so plain
/// [SharedPreferences] is used instead of the encrypted `storage` package.
abstract class ActiveDuelPointer {
  Future<void> set({required String duelId, required String userId});
  Future<void> clear();
  Future<({String duelId, String userId})?> read();
}

class ActiveDuelPointerImpl implements ActiveDuelPointer {
  static const _duelIdKey = 'active_duel_pointer.duel_id';
  static const _userIdKey = 'active_duel_pointer.user_id';

  @override
  Future<void> set({required String duelId, required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_duelIdKey, duelId);
    await prefs.setString(_userIdKey, userId);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_duelIdKey);
    await prefs.remove(_userIdKey);
  }

  @override
  Future<({String duelId, String userId})?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final duelId = prefs.getString(_duelIdKey);
    final userId = prefs.getString(_userIdKey);
    if (duelId == null || userId == null) return null;
    return (duelId: duelId, userId: userId);
  }
}
