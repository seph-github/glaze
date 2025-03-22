import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs.dart';

part 'onboarding_provider.g.dart';

@riverpod
OnboardingProvider onboarding(ref) {
  return OnboardingProvider(
    preferences: ref.read(sharedPrefsProvider),
  );
}

class OnboardingProvider {
  const OnboardingProvider({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static String onBoardingCompletedKey = 'onBoardingCompleted';

  Future<void> setOnBoardingComplete(bool value) async {
    await _preferences.setBool(onBoardingCompletedKey, value);
  }

  bool get completeOnBoarding =>
      _preferences.getBool(onBoardingCompletedKey) ?? false;
}
