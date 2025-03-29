import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs.dart';

part 'onboarding_provider.g.dart';

@riverpod
OnboardingProvider onboarding(ref) {
  return OnboardingProvider(
    sharedPreferences: ref.read(sharedPrefsProvider),
  );
}

@riverpod
List<Map<String, String>> onboardingData(ref) {
  return ref.watch(onboardingProvider).onboardingData;
}

@riverpod
class OnboardingDataNotifier extends _$OnboardingDataNotifier {
  @override
  int build() => 0;

  void next() => state++;
}

class OnboardingProvider {
  OnboardingProvider({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  final SharedPreferences _sharedPref;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Complete Your Profile',
      'subtitle': 'Start by setting up your profile\nwith a username and bio.',
      'image': 'assets/images/svg/complete_your_profile_illustration.svg',
    },
    {
      'title': 'Upload Your First Moment',
      'subtitle': 'Share your talent with the community\nby uploading a video.',
      'image': 'assets/images/svg/upload_your_first_moment_illustration.svg',
    },
    {
      'title': 'Discover Moments',
      'subtitle': 'Find amazing content from other\ncreators in your area.',
      'image': 'assets/images/svg/discover_moments_illustrations.svg',
    },
    {
      'title': 'Enter Challenges',
      'subtitle': 'Participate in contests to win\nprizes and get recognized.',
      'image': 'assets/images/svg/enter_challenges_illustrations.svg',
    },
    {
      'title': 'Invite Friends',
      'subtitle': 'Grow your network by inviting\nfriends to join Glaze.',
      'image': 'assets/images/svg/invite_friends_illustrations.svg',
    }
  ];

  static const String onboardingKey = 'onboardingCompleted';

  Future<void> setOnBoardingComplete(bool value) async {
    await _sharedPref.setBool(onboardingKey, value);
  }

  bool get completeOnBoarding => _sharedPref.getBool(onboardingKey) ?? false;
}
