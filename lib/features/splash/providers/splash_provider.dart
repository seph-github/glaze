import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs.dart';

part 'splash_provider.g.dart';

@riverpod
SplashProvider splash(ref) {
  return SplashProvider(
    preferences: ref.read(sharedPrefsProvider),
  );
}

class SplashProvider {
  const SplashProvider({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static String splashCompletedKey = 'splashCompleted';

  Future<void> setSplashComplete(bool value) async {
    await _preferences.setBool(splashCompletedKey, value);
  }

  bool get completeSplash => _preferences.getBool(splashCompletedKey) ?? false;
}
