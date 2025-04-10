import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recruiter_interests_list_provider.g.dart';

@Riverpod(keepAlive: true)
class RecruiterInterestsNotifier extends _$RecruiterInterestsNotifier {
  @override
  List<String> build() => [];

  void addToInterestList(String value) {
    if (state.contains(value)) {
      state.remove(value);
    } else {
      state.add(value);
    }
    print('new state: $state');
  }

  void initializedInterest(List<String> value) {
    state = value;
  }
}
