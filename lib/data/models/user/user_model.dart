// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/data/models/glaze/glaze_model.dart';
import 'package:glaze/data/models/video/video_model.dart';

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
    List<GlazeModel>? glazes,
    List<VideoModel>? videos,
    String? badges,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
