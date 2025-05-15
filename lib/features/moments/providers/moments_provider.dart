// ignore_for_file: unused_element

import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/challenges/models/challenge/challenge.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:glaze/features/moments/services/moments_services.dart';
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
    @Default(null) VideoContent? video,
    @Default([]) List<Challenge> challenges,
    @Default([]) List<Challenge> upcomingChallenges,
    @Default(false) bool isLoading,
    @Default(null) Exception? error,
    @Default(true) hasMoreItems,
    @Default(false) bool isPaginating,
  }) = _MomentsState;
}

@Riverpod(keepAlive: true)
class MomentsNotifier extends _$MomentsNotifier {
  @override
  MomentsState build() {
    return const MomentsState();
  }

  void _setNewResponse(String response) {
    state = state.copyWith(isLoading: false, response: response);
  }

  void _setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  int offset = 0;
  String? globalKeywords;
  String? globalFilterBy;
  int? globalPageLimit;

  Future<void> search({
    String? keywords,
    String? filterBy,
    int? pageLimit,
  }) async {
    state = state.copyWith(isLoading: true, error: null, hasMoreItems: true);

    try {
      globalKeywords = keywords;
      globalFilterBy = filterBy;
      globalPageLimit = pageLimit;
      offset = 0;
      final response = await MomentsServices().search(
        keywords: globalKeywords,
        filterBy: globalFilterBy,
        pageLimit: globalPageLimit,
        pageOffset: offset,
      );
      final hasMoreItems = response.length == 10;
      if (hasMoreItems) {
        offset += 10;
      }
      // state = state.copyWith(isLoading: false);

      state = state.copyWith(
          isLoading: false, videos: response, hasMoreItems: hasMoreItems);
    } catch (e) {
      state = state.copyWith(error: Exception(e), isLoading: false);
    }
  }

  Future<void> loadMoreSearch({
    String? keywords,
    String? filterBy,
    int? pageLimit,
  }) async {
    if (state.isPaginating || !state.hasMoreItems) return;
    state = state.copyWith(isPaginating: true, hasMoreItems: true);

    try {
      if (state.videos.isNotEmpty) {
        final List<VideoContent> response = await MomentsServices().search(
          keywords: globalKeywords,
          filterBy: globalFilterBy,
          pageLimit: globalPageLimit,
          pageOffset: offset,
        );
        final bool hasMoreItems = response.length == 10;
        if (hasMoreItems) {
          offset += 10;
        }

        final List<VideoContent> updatedResponse =
            List<VideoContent>.from(state.videos)..addAll(response);
        state = state.copyWith(
            videos: updatedResponse,
            isPaginating: false,
            hasMoreItems: hasMoreItems);
      }
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
      final upcomingChallenges =
          await MomentsServices().fetchUpcomingChallenges(user!.id);
      state = state.copyWith(
          upcomingChallenges: upcomingChallenges, isLoading: false);
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

      await ref.read(profileNotifierProvider.notifier).fetchProfile(user!.id);

      const resMessage = 'Success Uploaded Video';

      state = state.copyWith(
          isLoading: false, response: resMessage, video: response);
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> submitChallengeEntry({
    required String challengeId,
    required String videoId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final User? user = AuthServices().currentUser;
      // final challengeId = state.challenges[0].id;
      // final videoId = state.videos[0].id;
      await MomentsServices().submitChallengeEntry(
          userId: user!.id, challengeId: challengeId, videoId: videoId);

      state = state.copyWith(
          response: 'Success submitting entries', isLoading: false);
    } catch (e) {
      _setError(e);
    }
  }
}
