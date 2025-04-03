// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recruiter_profile_model.freezed.dart';
part 'recruiter_profile_model.g.dart';

@freezed
class RecruiterProfileModel with _$RecruiterProfileModel {
  const factory RecruiterProfileModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') String? fullName,
    required String username,
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
  }) = _RecruiterProfileModel;

  factory RecruiterProfileModel.fromJson(Map<String, dynamic> json) =>
      _$RecruiterProfileModelFromJson(json);
}
