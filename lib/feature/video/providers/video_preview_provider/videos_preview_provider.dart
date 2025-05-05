import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/models/video_content/video_content.dart';

part 'videos_preview_provider.g.dart';

@riverpod
class VideosPreview extends _$VideosPreview {
  @override
  List<VideoContent> build() {
    return [];
  }

  void setVideos(List<VideoContent> videos) {
    state = videos;
  }

  void addVideos(List<VideoContent> newVideos) {
    state = [
      ...state,
      ...newVideos
    ];
  }

  void updateVideo(String videoId, int newGlazeCount, bool hasGlazed) {
    print('before effect ${state.where((video) {
      return video.id == videoId;
    })}');
    print('called this function, video id $videoId, count $newGlazeCount, glazed? $hasGlazed');
    state = [
      for (final video in state)
        if (video.id == videoId) video.copyWith(glazesCount: newGlazeCount, hasGlazed: hasGlazed) else video
    ];
    print('after effect ${state.where((video) {
      return video.id == videoId;
    })}');
  }
}
