import 'package:exception/exception.dart';
import 'package:health_duel/core/offline_queue/data/models/queued_action_model.dart';
import 'package:storage/storage.dart';

/// Hive-backed persistence for [QueuedActionModel] entries, keyed by
/// [QueuedActionModel.id]. Wraps every box operation with `processBox`
/// (ADR-002) so Hive errors surface as `CoreException`s the repository can
/// map to `Failure`s.
class OfflineQueueLocalDataSource {
  const OfflineQueueLocalDataSource(this._database);

  static const _module = 'OFFLINE_QUEUE';

  final Database<String> _database;

  Future<void> put(QueuedActionModel model) => processBox(
        module: _module,
        function: 'PUT',
        call: () async {
          await _database.box.put(model.id, model.toJson());
        },
      );

  Future<void> removeByDedupKey(String dedupKey) => processBox(
        module: _module,
        function: 'REMOVE_BY_DEDUP_KEY',
        call: () async {
          final keysToRemove = <dynamic>[];
          for (final key in _database.box.keys) {
            final raw = _database.box.get(key);
            if (raw == null) continue;
            if (QueuedActionModel.fromJson(raw).dedupKey == dedupKey) {
              keysToRemove.add(key);
            }
          }
          await _database.box.deleteAll(keysToRemove);
        },
      );

  Future<void> remove(String id) => processBox(
        module: _module,
        function: 'REMOVE',
        call: () => _database.box.delete(id),
      );

  Future<void> update(QueuedActionModel model) => put(model);

  Future<List<QueuedActionModel>> getAll() => processBox(
        module: _module,
        function: 'GET_ALL',
        call: () async =>
            _database.box.values.map(QueuedActionModel.fromJson).toList(),
      );

  Future<void> clear() => processBox(
        module: _module,
        function: 'CLEAR',
        call: () => _database.box.clear(),
      );
}
