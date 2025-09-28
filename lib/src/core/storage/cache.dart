// lib/src/core/storage/cache.dart
import 'dart:convert';
import 'package:hive/hive.dart';

class CacheStore {
  CacheStore(this._box);
  final Box _box;

  Future<void> writeJson(
    String key,
    Object data, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final payload = {
      'data': data,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl.inMilliseconds,
    };
    await _box.put(key, jsonEncode(payload));
  }

  T? readJson<T>(String key, T Function(Object?) mapper) {
    final raw = _box.get(key);
    if (raw is! String) return null;
    final map = jsonDecode(raw);
    final ts = map['ts'] as int?;
    final ttl = map['ttl'] as int?;
    if (ts == null || ttl == null) return null;
    final expired = DateTime.now().millisecondsSinceEpoch > ts + ttl;
    if (expired) return null;
    return mapper(map['data']);
  }

  Future<void> remove(String key) => _box.delete(key);
}
