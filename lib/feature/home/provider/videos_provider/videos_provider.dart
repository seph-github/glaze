import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/video_content/video_content.dart';

part 'videos_provider.g.dart';

@riverpod
class Videos extends _$Videos {
  @override
  List<VideoContent> build() {
    return []; // initial empty list
  }

  // Set the initial list of videos
  void setVideos(List<VideoContent> videos) {
    state = videos;
  }

  // Add new videos to the list
  void addVideos(List<VideoContent> newVideos) {
    state = [
      ...state,
      ...newVideos
    ];
  }

  // Update a specific video (e.g., glaze count or hasGlazed)
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
