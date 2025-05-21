import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_interests_list_provider.g.dart';

@Riverpod(keepAlive: true)
// @riverpod
class ProfileInterestsListNotifier extends _$ProfileInterestsListNotifier {
  @override
  List<String> build() => [];

  void addToInterestList(String value) {
    final updatedState = state.contains(value)
        ? state.where((item) => item != value).toList()
        : [
            ...state,
            value
          ];
    state = updatedState;
  }

  List<String> updateInterestsList(List<String> interests, String? value) {
    state = interests;

    if (value != null) {
      if (state.contains(value)) {
        state = state.where((item) => item != value).toList();
      } else {
        state = [
          ...state,
          value
        ];
      }
    }

    return state;
  }
}
