import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/moments/models/challenge.dart';
import 'package:glaze/feature/moments/services/moments_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

import '../../auth/services/auth_services.dart';

part 'moments_provider.freezed.dart';
part 'moments_provider.g.dart';

@freezed
abstract class MomentsState with _$MomentsState {
  const factory MomentsState({
    @Default([]) List<Challenge> upcomingChallenges,
    @Default(false) bool isLoading,
    @Default(null) Exception? error,
  }) = _MomentsState;
}

@riverpod
class MomentsNotifier extends _$MomentsNotifier {
  @override
  MomentsState build() {
    Future.microtask(() async => await getUpcomingChallenges());
    return const MomentsState();
  }

  Future<void> getUpcomingChallenges() async {
    state = state.copyWith(isLoading: true);
    try {
      final User? user = AuthServices().currentUser;
      final challenges =
          await MomentsServices().fetchUpcomingChallenges(user!.id);
      state = state.copyWith(upcomingChallenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }
}
