import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs.dart';
import '../../../gen/assets.gen.dart';

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

  void next() {
    log('before $state');
    state++;
    log('state $state');
  }
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
      'image': Assets.images.png.profileComplete.path,
    },
    {
      'title': 'Upload Your First Moment',
      'subtitle': 'Share your talent with the community\nby uploading a video.',
      'image': Assets.images.png.uploadFirstMoment.path,
    },
    {
      'title': 'Discover Moments',
      'subtitle': 'Find amazing content from other\ncreators in your area.',
      'image': Assets.images.png.discoverAndExplore.path,
    },
    {
      'title': 'Enter Challenges',
      'subtitle': 'Participate in contests to win\nprizes and get recognized.',
      'image': Assets.images.png.joinChallenge.path,
    },
    {
      'title': 'Invite Friends',
      'subtitle': 'Grow your network by inviting\nfriends to join Glaze.',
      'image': Assets.images.png.friendInvite.path,
    }
  ];

  static const String onboardingKey = 'onboardingCompleted';

  Future<void> setOnBoardingComplete(bool value) async {
    await _sharedPref.setBool(onboardingKey, value);
  }

  bool get completeOnBoarding => _sharedPref.getBool(onboardingKey) ?? false;
}
