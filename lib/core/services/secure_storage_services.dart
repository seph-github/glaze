import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class SecureCache {
  static const _storage = FlutterSecureStorage();

  /// Load and deserialize object of type [T] using [fromJson]
  static Future<T?> load<T>(String key, FromJson<T> fromJson) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    return fromJson(json.decode(jsonString));
  }

  /// Save object of type [T] that implements `toJson()`
  static Future<void> save<T>(String key, T value, Map<String, dynamic> Function() toJson) async {
    final jsonString = json.encode(toJson());
    await _storage.write(key: key, value: jsonString);
  }

  static Future<void> clear(String key) async {
    await _storage.delete(key: key);
  }
}
