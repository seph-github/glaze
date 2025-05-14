import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:glaze/feature/moments/services/moments_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

import '../../auth/services/auth_services.dart';
import '../../home/services/video_content_services.dart';
import '../../profile/provider/profile_provider/profile_provider.dart';

part 'moments_provider.freezed.dart';
part 'moments_provider.g.dart';

@freezed
abstract class MomentsState with _$MomentsState {
  const factory MomentsState({
    @Default(null) String? response,
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
    return const MomentsState();
  }

  // void _setNewResponse(String response) {
  //   state = state.copyWith(isLoading: false, response: response);
  // }

  void _setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<void> search({
    String? keywords,
    String? filterBy,
    int? pageLimit,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final challenges = await MomentsServices().fetchAllChallenges();
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }

  Future<void> getUpcomingChallenges() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final User? user = AuthServices().currentUser;
      final upcomingChallenges = await MomentsServices().fetchUpcomingChallenges(user!.id);
      state = state.copyWith(upcomingChallenges: upcomingChallenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }

  Future<void> uploadVideoContent({
    required File file,
    required File thumbnail,
    required String title,
    required String caption,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true, error: null, response: null);
    try {
      final User? user = AuthServices().currentUser;

      final response = await VideoContentServices().uploadVideoContent(
        file: file,
        thumbnail: thumbnail,
        userId: user?.id ?? '',
        title: title,
        caption: caption,
        category: category,
      );
      print('response video upload $response');

      await ref.read(profileNotifierProvider.notifier).fetchProfile(user!.id);

      state = state.copyWith(isLoading: false, response: response);
    } catch (e) {
      _setError(e);
    }
  }
}
