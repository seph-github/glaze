import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/local/shared_prefs.dart';

part 'recruiter_profile_provider.g.dart';

@riverpod
RecruiterProfileProvider recruiterProfile(ref) {
  return RecruiterProfileProvider(
    preferences: ref.read(sharedPrefsProvider),
  );
}

class RecruiterProfileProvider {
  const RecruiterProfileProvider({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static String recruiterProfileCompletedKey = 'splashCompleted';

  Future<void> setRecruiterProfileComplete(bool value) async {
    await _preferences.setBool(recruiterProfileCompletedKey, value);
  }

  bool get completeRecruiterProfile => _preferences.getBool(recruiterProfileCompletedKey) ?? false;
}
