import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recruiter_interests_list_provider.g.dart';

@Riverpod(keepAlive: true)
class RecruiterInterestsNotifier extends _$RecruiterInterestsNotifier {
  @override
  List<String> build() => [];

  List<String> initializeInterestsList(List<String> interests) {
    if (interests.isNotEmpty) {
      state = interests;
    } else {
      state = [];
    }
    return state;
  }

  void addToInterestList(String value) {
    if (state.contains(value)) {
      // Remove the interest if it already exists
      state = state.where((item) => item != value).toList();
    } else {
      // Add the interest if it doesn't exist
      state = [
        ...state,
        value
      ];
    }
  }

  void updateInterestsList(List<String> interests, String? value) {
    if (value != null) {
      // Remove the interest if it already exists
      state = state.where((item) => item != value).toList();
    }
    if (interests.isNotEmpty) {
      state = interests;
    } else {
      state = [];
    }
  }
}
