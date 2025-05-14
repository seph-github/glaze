import 'package:flutter/material.dart';
import 'package:glaze/core/styles/theme.dart';
import 'package:glaze/data/local/shared_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_theme_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsTheme extends _$SettingsTheme {
  @override
  ThemeData build() {
    final SharedPreferences sharedPreferences = ref.watch(sharedPrefsProvider);

    final systemTheme = SystemThemePreferences(preferences: sharedPreferences).systemTheme;

    if (systemTheme == ThemeMode.light.name) {
      return lightTheme;
    }
    return darkTheme;
  }

  Future<void> toggleTheme() async {
    final SharedPreferences sharedPreferences = ref.watch(sharedPrefsProvider);

    state = state == darkTheme ? lightTheme : darkTheme;

    ThemeMode mode = state == darkTheme ? ThemeMode.light : ThemeMode.dark;

    await SystemThemePreferences(preferences: sharedPreferences).setSystemTheme(mode);
  }
}

class SystemThemePreferences {
  const SystemThemePreferences({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static String systemThemeKey = 'systemTheme';

  Future<void> setSystemTheme(ThemeMode mode) async {
    await _preferences.setString(systemThemeKey, mode.name);
  }

  String get systemTheme => _preferences.getString(systemThemeKey) ?? ThemeMode.dark.name;
}
