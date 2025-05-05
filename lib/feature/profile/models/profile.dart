// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../home/models/video_content/video_content.dart';

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
    @Default([]) List<VideoContent>? videos,
    @JsonKey(name: 'username_id') String? usernameId,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'is_onboarding_completed') bool? isOnboardingCompleted,
    @JsonKey(name: 'is_completed_profile') bool? isCompletedProfile,
    @Default([]) List<Interact> followers,
    @Default([]) List<Interact> following,
    @Default([]) List<Glaze> glazes,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

@freezed
class Interact with _$Interact {
  const factory Interact({
    required String id,
    required String username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
  }) = _Interact;

  factory Interact.fromJson(Map<String, dynamic> json) => _$InteractFromJson(json);
}

@freezed
class Glaze with _$Glaze {
  const factory Glaze({
    required String id,
    required Glazer glazer,
    @JsonKey(name: 'user_id') required String userId,
    // @JsonKey(name: 'donut_id') required String donutId,
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Glaze;

  factory Glaze.fromJson(Map<String, dynamic> json) => _$GlazeFromJson(json);
}

@freezed
class Glazer with _$Glazer {
  const factory Glazer({
    required String id,
    required String username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
  }) = _Glazer;

  factory Glazer.fromJson(Map<String, dynamic> json) => _$GlazerFromJson(json);
}
