import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/home/models/video_content.dart';
import 'package:glaze/feature/moments/services/moments_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

import '../../auth/services/auth_services.dart';

part 'moments_provider.freezed.dart';
part 'moments_provider.g.dart';

@freezed
abstract class MomentsState with _$MomentsState {
  const factory MomentsState({
    @Default([]) List<VideoContent> videos,
    @Default([]) List<Challenge> challenges,
    @Default([]) List<Challenge> upcomingChallenges,
    @Default(false) bool isLoading,
    @Default(null) Exception? error,
  }) = _MomentsState;
}

@Riverpod(keepAlive: true)
class MomentsNotifier extends _$MomentsNotifier {
  @override
  MomentsState build() {
    // Future.microtask(() async => await getUpcomingChallenges());
    return const MomentsState();
  }

  Future<void> search({
    String? keywords,
    String? filterBy,
    int? pageLimit,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await MomentsServices().search(
        keywords: keywords,
        filterBy: filterBy,
        pageLimit: pageLimit,
      );

      state = state.copyWith(isLoading: false, videos: response);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }

  Future<void> getChallenges() async {
    state = state.copyWith(isLoading: true);
    try {
      final challenges = await MomentsServices().fetchAllChallenges();
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }

  Future<void> getUpcomingChallenges() async {
    state = state.copyWith(isLoading: true);
    try {
      final User? user = AuthServices().currentUser;
      final upcomingChallenges = await MomentsServices().fetchUpcomingChallenges(user!.id);
      state = state.copyWith(upcomingChallenges: upcomingChallenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }
}
