// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/data/models/glaze/glaze_model.dart';

import '../video/videos.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? username,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    String? bio,
    String? provider,
    String? badges,
    @JsonKey(name: 'total_glazes') int? totalGlazes,
    @JsonKey(name: 'total_uploads') int? totalUploads,
    @JsonKey(name: 'total_followers') int? totalFollowers,
    @JsonKey(name: 'total_following') int? totalFollowing,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<GlazeModel>? glazes,
    List<Videos>? videos,
    @JsonKey(name: 'username_id') int? usernameId,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'is_onboarding_completed') bool? isOnboardingCompleted,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
