import 'dart:async';
import 'dart:developer';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import '../../models/video_content/video_content.dart';

import '../video_feed_provider/video_feed_provider.dart';
import '../videos_provider/videos_provider.dart'; // Assuming this contains the `videoFeedNotifierProvider`

part 'video_controller_notifier.g.dart';

@riverpod
class VideoControllerNotifier extends _$VideoControllerNotifier {
  static const int maxCacheSize = 3;

  late final PreloadPageController _pageController;
  late final Map<String, VideoPlayerController> controllerCache;
  late final List<String> accessOrder;
  late final Set<String> disposingControllers;
  late final Map<String, Completer<VideoPlayerController>> controllerCreationMap;
  late final List<VideoContent> videos;
  late int currentPage;

  PreloadPageController get pageController => _pageController;

  @override
  FutureOr<void> build() {
    _pageController = PreloadPageController();
    controllerCache = {};
    accessOrder = [];
    disposingControllers = {};
    controllerCreationMap = {};
    currentPage = 0;
    videos = ref.watch(videosProvider);
  }

  Future<void> pauseAllControllers() async {
    for (final controller in controllerCache.values) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        log('Pause all controllers error: $e');
      }
    }
  }

  Future<void> removeController(String videoId) async {
    if (disposingControllers.contains(videoId)) return;

    disposingControllers.add(videoId);

    try {
      final controller = controllerCache.remove(videoId);
      accessOrder.remove(videoId);

      if (controller != null) {
        if (controller.value.isInitialized) {
          await controller.pause();
        }
        await controller.dispose();
      }
    } catch (e) {
      log('Remove controller error: $e');
    } finally {
      disposingControllers.remove(videoId);
    }
  }

  void enforceCacheLimit() {
    while (controllerCache.length > maxCacheSize && accessOrder.isNotEmpty) {
      final oldestId = accessOrder.removeAt(0);
      removeController(oldestId);
    }
  }

  void touchController(String videoId) {
    accessOrder.remove(videoId);
    accessOrder.add(videoId);
  }

  VideoPlayerController? getController(String videoId) {
    return controllerCache[videoId];
  }

  Future<VideoPlayerController?> getOrCreateController(VideoContent video) async {
    if (controllerCache.containsKey(video.id)) {
      touchController(video.id);
      return controllerCache[video.id];
    }

    if (controllerCreationMap.containsKey(video.id)) {
      return controllerCreationMap[video.id]!.future;
    }

    final completer = Completer<VideoPlayerController>();
    controllerCreationMap[video.id] = completer;

    try {
      final videoFile = await ref.watch(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);

      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      controller.setLooping(true);

      controllerCache[video.id] = controller;
      touchController(video.id);
      enforceCacheLimit();

      completer.complete(controller);
      return controller;
    } catch (e) {
      completer.completeError(e);
      return null;
    } finally {
      controllerCreationMap.remove(video.id);
    }
  }

  Future<void> playController(String videoId) async {
    final controller = controllerCache[videoId];
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        log('Play controller error: $e');
      }
    }
  }

  Future<void> initAndPlayVideo(int index) async {
    if (videos.isEmpty || index >= videos.length) return;

    final video = videos[index];
    final controller = await getOrCreateController(video);

    if (controller != null) {
      while (!controller.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (index != currentPage) return;

      await playController(video.id);
    }
  }

  Future<void> cleanupAndReinitializeCurrentVideo() async {
    if (videos.isEmpty || currentPage >= videos.length) return;

    await pauseAllControllers();
    final videoId = videos[currentPage].id;
    final controller = controllerCache[videoId];

    if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
      await removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await initAndPlayVideo(currentPage);
  }

  Future<void> disposeAllControllers() async {
    _pageController.dispose();

    final controllerIds = List<String>.from(controllerCache.keys);
    for (final id in controllerIds) {
      await removeController(id);
    }
    controllerCache.clear();
    accessOrder.clear();
  }

  Future<void> manageControllerWindow(int currentPage) async {
    if (videos.isEmpty) return;

    final windowStart = (currentPage - 1).clamp(0, videos.length - 1);
    final windowEnd = (currentPage + 1).clamp(0, videos.length - 1);
    final idsToKeep = <String>{};

    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < videos.length) idsToKeep.add(videos[i].id);
    }

    final idsToDispose = controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();

    for (final id in idsToDispose) {
      await removeController(id);
    }

    if (currentPage < videos.length) {
      await getOrCreateController(videos[currentPage]);
      if (windowStart < currentPage) {
        await getOrCreateController(videos[windowStart]);
      }
      if (windowEnd > currentPage && windowEnd < videos.length) {
        await getOrCreateController(videos[windowEnd]);
      }
    }
  }

  Future<void> handlePageChange(int newPage) async {
    if (videos.isEmpty || newPage >= videos.length) return;

    currentPage = newPage;
    await pauseAllControllers();

    try {
      await manageControllerWindow(newPage);
      await initAndPlayVideo(newPage);
      ref.read(videoFeedNotifierProvider.notifier).onPageChanged(newPage);
    } catch (e) {
      log('Handle page change error: $e');
    }
  }
}
