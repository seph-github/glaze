// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/data/models/glaze/glaze_model.dart';
import 'package:glaze/feature/home/models/video_content.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    String? username,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    String? bio,
    @JsonKey(name: 'interests') List<String>? interests,
    String? provider,
    String? badges,
    @JsonKey(name: 'total_glazes') int? totalGlazes,
    @JsonKey(name: 'total_uploads') int? totalUploads,
    @JsonKey(name: 'total_followers') int? totalFollowers,
    @JsonKey(name: 'total_following') int? totalFollowing,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<GlazeModel>? glazes,
    List<VideoContent>? videos,
    @JsonKey(name: 'username_id') String? usernameId,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'is_onboarding_completed') bool? isOnboardingCompleted,
    @JsonKey(name: 'is_completed_profile') bool? isCompletedProfile,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
