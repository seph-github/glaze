import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/home/provider/video_feed_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

import '../models/video_content/video_content.dart';

part 'video_controller_manager.freezed.dart';
part 'video_controller_manager.g.dart';

@freezed
class VideoControllerManagerState with _$VideoControllerManagerState {
  const factory VideoControllerManagerState({
    @Default({}) Map<String, VideoPlayerController> controllers,
  }) = _VideoControllerManagerState;
}

@riverpod
class VideoControllerManager extends _$VideoControllerManager {
  static const maxCacheSize = 3;

  final _accessOrder = <String>[];

  @override
  VideoControllerManagerState build() {
    return const VideoControllerManagerState();
  }

  Future<VideoPlayerController?> getOrCreate(VideoContent video) async {
    final id = video.id;
    log('🛠 Creating controller for ${video.id}');
    log('✅ Controller initialized for ${video.id}');

    if (state.controllers.containsKey(id)) {
      _touch(id);
      return state.controllers[id];
    }

    final file = await ref.read(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);
    log('📁 Loaded file for ${video.id}: ${file.path}');
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    controller.setLooping(true);

    final updatedControllers = {
      ...state.controllers,
      id: controller,
    };

    _accessOrder.add(id);
    _enforceCacheLimit();

    state = state.copyWith(controllers: updatedControllers);
    log('🧠 Controllers stored: ${state.controllers.keys}');
    return controller;
  }

  void _touch(String id) {
    _accessOrder.remove(id);
    _accessOrder.add(id);
  }

  void _enforceCacheLimit() {
    while (_accessOrder.length > maxCacheSize) {
      final oldest = _accessOrder.removeAt(0);
      _disposeController(oldest);
    }
  }

  Future<void> _disposeController(String id) async {
    final controller = state.controllers[id];
    if (controller != null) {
      await controller.dispose();
      final updatedMap = {
        ...state.controllers
      }..remove(id);
      state = state.copyWith(controllers: updatedMap);
    }
  }

  Future<void> preloadWindow(List<VideoContent> videos, int currentPage) async {
    final indices = [
      currentPage,
      if (currentPage > 0) currentPage - 1,
      if (currentPage < videos.length - 1) currentPage + 1,
    ];

    for (final index in indices) {
      log('⏳ Preloading controller for index=$index, id=${videos[index].id}');
      await getOrCreate(videos[index]);
    }

    // ✅ Trigger pagination if we're near the end
    final isNearEnd = currentPage >= videos.length - 2;
    if (isNearEnd) {
      log('📦 Near end of feed, fetching more videos...');
      await ref.read(videoFeedNotifierProvider.notifier).loadMoreVideos();
    }
  }

  Future<void> pauseAll() async {
    for (final c in state.controllers.values) {
      if (c.value.isInitialized && c.value.isPlaying) {
        await c.pause();
      }
    }
  }

  Future<void> disposeAll() async {
    for (final c in state.controllers.values) {
      await c.dispose();
    }
    _accessOrder.clear();
    state = state.copyWith(controllers: {});
  }
}
