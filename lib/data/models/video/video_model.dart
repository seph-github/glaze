// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'username') required String username,
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'video_url') required String videoUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'title') String? title,
    String? caption,
    String? category,
    @JsonKey(name: 'glazes_count') int? glazesCount,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}
