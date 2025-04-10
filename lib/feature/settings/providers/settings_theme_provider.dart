import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_theme_provider.g.dart';

@riverpod
class SettingsThemeProvider extends _$SettingsThemeProvider {
  @override
  ThemeData build() => ThemeData.dark();

  void toggleTheme() {
    state = state == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
  }
}
