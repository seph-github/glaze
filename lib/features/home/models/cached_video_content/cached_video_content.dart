import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';

part 'cached_video_content.freezed.dart';
part 'cached_video_content.g.dart';

@freezed
class CachedVideoContent with _$CachedVideoContent {
  const factory CachedVideoContent({
    List<VideoContent>? videoContents,
    List<dynamic>? controllers,
  }) = _CachedVideoContent;

  factory CachedVideoContent.fromJson(Map<String, dynamic> json) => _$CachedVideoContentFromJson(json);
}
