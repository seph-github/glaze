// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'video_url') required String videoUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    String? caption,
    String? category,
    @JsonKey(name: 'glaze_count') int? glazesCount,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}
