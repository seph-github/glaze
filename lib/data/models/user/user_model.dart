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
    required String email,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    String? bio,
    String? provider,
    String? badges,
    @JsonKey(name: 'total_glazes') int? totalGlazes,
    @JsonKey(name: 'total_uploads') int? totalUploads,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<GlazeModel>? glazes,
    List<Videos>? videos,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
