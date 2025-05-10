import 'package:glaze/data/local/shared_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'initial_app_use.g.dart';

@riverpod
InitialAppUseProvider initialAppUse(ref) {
  return InitialAppUseProvider(
    preferences: ref.read(sharedPrefsProvider),
  );
}

class InitialAppUseProvider {
  const InitialAppUseProvider({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static String initialAppUseCompletedKey = 'initialAppUseCompleted';

  Future<void> setInitialAppUseComplete(bool value) async {
    await _preferences.setBool(initialAppUseCompletedKey, value);
  }

  bool get completedInitialAppUse =>
      _preferences.getBool(initialAppUseCompletedKey) ?? false;
}
