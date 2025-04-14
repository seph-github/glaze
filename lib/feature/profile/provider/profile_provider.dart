import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/profile/services/profile_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/enum/profile_type.dart';
import '../models/profile.dart';
import '../models/recruiter_profile.dart';

part 'profile_provider.freezed.dart';
part 'profile_provider.g.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default('') String response,
    @Default(null) Profile? profile,
    @Default(null) Profile? viewUserProfile,
    @Default(null) RecruiterProfile? recruiterProfile,
    @Default(false) bool isLoading,
    @Default(null) Exception? error,
  }) = _ProfileState;

  const ProfileState._();
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> fetchProfile(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      // final User user = AuthServices().currentUser!;
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
      state = state.copyWith(isLoading: false, error: Exception(e));
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
      state = state.copyWith(isLoading: false, error: Exception(e));
    }
  }

  Future<void> fetchRecruiterProfile(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final recruiterProfile =
          await ProfileServices().fetchRecruiterProfile(id);
      state = state.copyWith(
        recruiterProfile: recruiterProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Exception(e));
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
      state = state.copyWith(isLoading: false, error: Exception(e));
    }
  }

  Future<void> updateProfile(
    String id, {
    required String fullName,
    required String phoneNumber,
    required List<String> interestList,
    required String organization,
    required File? profileImage,
    required File? identification,
    required ProfileType role,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ProfileServices().updateProfile(
        id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        interestList: interestList,
        organization: organization,
        profileImage: profileImage,
        identification: identification,
        role: role,
      );
      state = state.copyWith(response: 'Created profile', isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Exception(e));
    }
  }
}
