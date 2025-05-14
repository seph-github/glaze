import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/home/provider/video_feed_provider/video_feed_provider.dart';
import 'package:glaze/features/home/services/video_content_services.dart';
import 'package:glaze/features/profile/services/profile_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/services/secure_storage_services.dart';
import '../../../home/models/video_content/video_content.dart';
import '../../models/profile/profile.dart';
import '../../models/recruiter_profile/recruiter_profile.dart';

part 'profile_provider.freezed.dart';
part 'profile_provider.g.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(null) String? response,
    @Default(null) Profile? profile,
    @Default(null) Profile? viewUserProfile,
    @Default(null) RecruiterProfile? recruiterProfile,
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
  }) = _ProfileState;

  const ProfileState._();
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  void setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<void> fetchProfile(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await ProfileServices().fetchUserProfile(id);

      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          error: Exception('No profile'),
        );
      }

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      final profile = await SecureCache.load(
        'user_profile',
        (json) => Profile.fromJson(json),
      );
      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );

      // setError(e);
    }
  }

  Future<void> viewUserProfile(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await ProfileServices().viewUserProfile(id);

      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          error: Exception('No profile'),
        );
      }

      state = state.copyWith(
        viewUserProfile: profile,
        isLoading: false,
      );
    } catch (e) {
      setError(e);
    }
  }

  Future<void> fetchRecruiterProfile(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final recruiterProfile = await ProfileServices().fetchRecruiterProfile(id);
      state = state.copyWith(
        recruiterProfile: recruiterProfile,
        isLoading: false,
      );
    } catch (e) {
      setError(e);
    }
  }

  Future<void> setFlagsCompleted(
    String id, {
    required String table,
    Map<String, dynamic>? data,
    required String column,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ProfileServices().setFlagsCompleted(
        id,
        table: table,
        data: data,
        column: column,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> updateProfile({
    required String id,
    String? bio,
    String? username,
    String? email,
    String? fullName,
    String? countryCode,
    String? phoneNumber,
    List<String>? interestList,
    String? organization,
    File? profileImage,
    File? identification,
    String? password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ProfileServices().updateProfile(
        id: id,
        bio: bio,
        username: username,
        email: email,
        fullName: fullName,
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        interestList: interestList,
        organization: organization,
        profileImage: profileImage,
        identification: identification,
      );
      state = state.copyWith(response: 'Created profile', isLoading: false);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> deleteVideoById(String id) async {
    state = state.copyWith(isLoading: true, error: null, response: null);
    try {
      final res = await VideoContentServices().deleteVideoById(id).then((_) {
        () => ref.refresh(videoFeedNotifierProvider);
      });

      final updatedVideos = List<VideoContent>.from(state.profile?.videos ?? [])..removeWhere((video) => video.id == id);

      final updatedProfile = state.profile?.copyWith(videos: updatedVideos);

      state = state.copyWith(
        isLoading: false,
        response: res ?? '',
        profile: updatedProfile,
      );
    } catch (e) {
      setError(e);
    }
  }
}
