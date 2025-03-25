// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'videos.freezed.dart';
part 'videos.g.dart';

@freezed
class Videos with _$Videos {
  const factory Videos({
    @JsonKey(name: 'video_id') String? videoId,
    String? caption,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Videos;

  factory Videos.fromJson(Map<String, dynamic> json) => _$VideosFromJson(json);
}
