import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/duel/data/background/active_duel_pointer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ActiveDuelPointer pointer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    pointer = ActiveDuelPointerImpl();
  });

  group('ActiveDuelPointerImpl', () {
    test('read returns null when nothing has been set', () async {
      expect(await pointer.read(), isNull);
    });

    test('read returns the pointer after set', () async {
      await pointer.set(duelId: 'duel-1', userId: 'user-1');

      final result = await pointer.read();

      expect(result, (duelId: 'duel-1', userId: 'user-1'));
    });

    test('read returns null after clear', () async {
      await pointer.set(duelId: 'duel-1', userId: 'user-1');
      await pointer.clear();

      expect(await pointer.read(), isNull);
    });
  });
}
