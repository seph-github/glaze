// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recruiter_profile.freezed.dart';
part 'recruiter_profile.g.dart';

@freezed
class RecruiterProfile with _$RecruiterProfile {
  const factory RecruiterProfile({
    String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') String? fullName,
    String? username,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    String? organization,
    List<String>? interests,
    @JsonKey(name: 'identification_url') String? identificationUrl,
    @JsonKey(name: 'is_verified') bool? isVerified,
    @JsonKey(name: 'subscription_status') String? subscriptionStatus,
    @JsonKey(name: 'subscription_started_at') DateTime? subscriptionStartedAt,
    @JsonKey(name: 'subscription_expires_at') DateTime? subscriptionExpiresAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'is_profile_completed') bool? isProfileCompleted,
  }) = _RecruiterProfile;

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) =>
      _$RecruiterProfileFromJson(json);
}
