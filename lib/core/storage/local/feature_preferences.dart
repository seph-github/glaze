// ignore_for_file: pattern_never_matches_value_type

import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'feature_preferences.g.dart';

@Riverpod(keepAlive: true)
Future<FeaturePreferences> featurePreferences(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return FeaturePreferences(prefs);
}

class FeaturePreferences {
  final SharedPreferences _prefs;

  FeaturePreferences(this._prefs);

  // Basic types
  Future<void> set<T>(String key, T value) async {
    switch (T) {
      case String _:
        await _prefs.setString(key, value as String);
        break;
      case int _:
        await _prefs.setInt(key, value as int);
        break;
      case double _:
        await _prefs.setDouble(key, value as double);
        break;
      case bool _:
        await _prefs.setBool(key, value as bool);
        break;
      case List<String> _:
        await _prefs.setStringList(key, value as List<String>);
        break;
      default:
        // Custom object
        final json = jsonEncode(value);
        await _prefs.setString(key, json);
    }
  }

  T? get<T>(String key, T Function(Map<String, dynamic> json)? fromJson) {
    switch (T) {
      case String _:
        return _prefs.getString(key) as T?;
      case int _:
        return _prefs.getInt(key) as T?;
      case double _:
        return _prefs.getDouble(key) as T?;
      case bool _:
        return _prefs.getBool(key) as T?;
      case List<String> _:
        return _prefs.getStringList(key) as T?;
      default:
        final jsonStr = _prefs.getString(key);
        if (jsonStr == null || fromJson == null) return null;
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return fromJson(json);
    }
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool contains(String key) => _prefs.containsKey(key);
}
