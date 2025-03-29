import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_view_mode_provider.g.dart';

@riverpod
class ProfileViewModeNotifier extends _$ProfileViewModeNotifier {
  @override
  bool build() => false;

  bool changeViewMode(bool mode) => state = mode;
}
