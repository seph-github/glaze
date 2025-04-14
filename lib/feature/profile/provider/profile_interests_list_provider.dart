import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_interests_list_provider.g.dart';

// @Riverpod(keepAlive: true)
@riverpod
class ProfileInterestsNotifier extends _$ProfileInterestsNotifier {
  @override
  List<String> build() => [];

  List<String> addToInterestList(String value) {
    print('current state before update: $state');
    final updatedState = state.contains(value)
        ? state.where((item) => item != value).toList()
        : [...state, value];
    print('updated state: $updatedState');
    state = updatedState; // Update the provider's state
    return updatedState; // Return the updated state
  }

  List<String> updateInterestsList(List<String> interests, String? value) {
    state = interests;

    if (value != null) {
      if (state.contains(value)) {
        state = state.where((item) => item != value).toList();
      } else {
        state = [...state, value];
      }
    }

    return state;
  }
}
