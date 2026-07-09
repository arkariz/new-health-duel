import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Duel Share Service
///
/// Thin wrapper around the platform share sheet. Lives in the presentation
/// layer (not domain) since it depends directly on `share_plus`, a
/// platform-facing package with no business logic of its own.
///
/// Not a one-member-abstract-class smell: this exists specifically so the
/// duel result screen can inject a mock in tests, since `share_plus`'s
/// platform channel call can't run in `flutter_test`.
// ignore: one_member_abstracts
abstract class DuelShareService {
  /// Share a PNG image via the system share sheet.
  ///
  /// [bytes] is the raw PNG data (in-memory — no temp file needed).
  Future<void> shareImage({
    required Uint8List bytes,
    required String fileName,
    String? text,
  });
}

class DuelShareServiceImpl implements DuelShareService {
  const DuelShareServiceImpl();

  @override
  Future<void> shareImage({
    required Uint8List bytes,
    required String fileName,
    String? text,
  }) async {
    final file = XFile.fromData(bytes, mimeType: 'image/png', name: fileName);
    await SharePlus.instance.share(ShareParams(files: [file], text: text));
  }
}
