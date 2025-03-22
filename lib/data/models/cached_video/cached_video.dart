import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/data/models/video/video_model.dart';

part 'cached_video.freezed.dart';
part 'cached_video.g.dart';

@freezed
class CachedVideo with _$CachedVideo {
  const factory CachedVideo({
    List<VideoModel>? model,
    List<dynamic>? controllers,
  }) = _CachedVideo;

  factory CachedVideo.fromJson(Map<String, dynamic> json) =>
      _$CachedVideoFromJson(json);
}
