import 'package:flutter/widgets.dart';
import 'package:glaze/feature/home/provider/video_feed_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

import '../models/video_content/video_content.dart';

part 'video_cache_controller.g.dart';

@riverpod
class VideoCacheController extends _$VideoCacheController {
  @override
  void build() {}

  PreloadPageController get pageController => _pageController;
  List<VideoContent> get videos => _videos;

  final int _maxCacheSize = 3;
  List<VideoContent> _videos = [];
  int _currentPage = 0;
  final PreloadPageController _pageController = PreloadPageController();
  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = <String>{};

  void get initializeFirstVideo => _initializeFirstVideo();

  Future<void> get cleanUpAndReinitializeCurrentVideo async => await _cleanupAndReinitializeCurrentVideo();

  Future<void> get disposeAllControllers async => await _disposeAllControllers();

  Future<void> handlePageChange(int newPage) async => await _handlePageChange(newPage);

  VideoPlayerController? videoController(String videoId) => _getController(videoId);

  void _initializeFirstVideo() {
    print('called video');
    Future.microtask(() async {
      await ref.read(videoFeedNotifierProvider.notifier).loadVideos();
      final state = ref.watch(videoFeedNotifierProvider).videos;
      if (state.isNotEmpty) {
        print('video are load $state');
        _videos = state;

        await _initAndPlayVideo(0);
      }
    });
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    await _pauseAllControllers();

    final videoId = _videos[_currentPage].id;
    final controller = _getController(videoId);

    if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _initAndPlayVideo(_currentPage);
  }

  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;

    final video = _videos[index];
    await _getOrCreateController(video);
    await _playController(video.id);
  }

  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  Future<VideoPlayerController?> _getOrCreateController(VideoContent video) async {
    if (_controllerCache.containsKey(video.id)) {
      _touchController(video.id);
      return _controllerCache[video.id];
    }

    try {
      final videoFile = await ref.read(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      controller.setLooping(true);
      _controllerCache[video.id] = controller;
      _touchController(video.id);
      _enforceCacheLimit();
      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  Future<void> _pauseAllControllers() async {
    final controllers = List<VideoPlayerController>.from(_controllerCache.values);

    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;

    _disposingControllers.add(videoId);

    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        // Remove from cache immediately
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);

        // Pause and dispose
        try {
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      _removeController(oldestId);
    }
  }

  Future<void> _disposeAllControllers() async {
    _pageController.dispose();

    final controllerIds = List<String>.from(_controllerCache.keys);
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;

    final windowStart = (currentPage - 1).clamp(0, _videos.length - 1);
    final windowEnd = (currentPage + 1).clamp(0, _videos.length - 1);

    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) {
        idsToKeep.add(_videos[i].id);
      }
    }

    final idsToDispose = _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      await _removeController(id);
    }

    if (currentPage < _videos.length) {
      // Current page first
      await _getOrCreateController(_videos[currentPage]);

      // Then previous page if in range
      if (windowStart < currentPage && windowStart >= 0) {
        await _getOrCreateController(_videos[windowStart]);
      }

      // Then next page if in range
      if (windowEnd > currentPage && windowEnd < _videos.length) {
        await _getOrCreateController(_videos[windowEnd]);
      }
    }
  }

  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length) return;

    final previousPage = _currentPage;
    _currentPage = newPage;

    final isFastScroll = (newPage - previousPage).abs() > 1;

    await _pauseAllControllers();

    try {
      if (isFastScroll) {
        // In fast scroll, dispose all except target
        final videoId = _videos[newPage].id;
        final idsToDispose = List<String>.from(_controllerCache.keys);

        for (final id in idsToDispose) {
          if (id != videoId) {
            await _removeController(id);
          }
        }
      }

      await _manageControllerWindow(newPage);

      if (_videos.isNotEmpty && newPage < _videos.length) {
        await _initAndPlayVideo(newPage);
      }

      ref.read(videoFeedNotifierProvider.notifier).onPageChanged(newPage);
    } catch (e) {
      debugPrint('Error handling page change: $e');
    }
  }
}
