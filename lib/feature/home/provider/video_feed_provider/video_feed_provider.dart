import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:glaze/feature/home/services/video_content_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

part 'video_feed_provider.freezed.dart';
part 'video_feed_provider.g.dart';

@freezed
abstract class VideoFeedState with _$VideoFeedState {
  const factory VideoFeedState({
    @Default([]) List<VideoContent> videos,
    @Default(false) bool isLoading,
    @Default(false) bool isPaginating,
    @Default(true) bool hasMoreVideos,
    @Default(0) int currentVideoIndex,
    @Default({}) Set<String> preloadedVideoUrls,
    @Default(null) dynamic error,
  }) = _VideoFeedState;

  const VideoFeedState._();
}

@riverpod
class VideoFeedNotifier extends _$VideoFeedNotifier {
  @override
  VideoFeedState build() {
    Future.microtask(() async => await loadVideos());
    return const VideoFeedState();
  }

  final _videoServices = VideoContentServices();
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};
  bool _isPreloadingMore = false;
  int offset = 0;

  Future<void> loadVideos() async {
    state = state.copyWith(isLoading: true);
    try {
      final videos = await _videoServices.loadVideos(offset);
      final hasMoreVideos = videos.length == 2;
      if (hasMoreVideos) {
        offset += 2;
      }
      state = state.copyWith(isLoading: false, videos: videos, hasMoreVideos: hasMoreVideos, currentVideoIndex: 0);

      if (videos.isNotEmpty) {
        preloadNextVideos();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refreshVideos() async {
    offset = 0;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final videos = await _videoServices.loadVideos(offset);
      final hasMore = videos.length == 2;
      if (hasMore) offset += 2;

      _preloadQueue.clear();
      _preloadedFiles.clear();

      state = state.copyWith(
        videos: videos,
        isLoading: false,
        hasMoreVideos: hasMore,
        currentVideoIndex: 0,
        preloadedVideoUrls: {},
      );

      // Re-preload fresh videos
      if (videos.isNotEmpty) {
        preloadNextVideos();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMoreVideos() async {
    if (state.isPaginating || !state.hasMoreVideos) return;
    state = state.copyWith(isPaginating: true);

    try {
      if (state.videos.isNotEmpty) {
        final List<VideoContent> moreVideos = await _videoServices.loadVideos(offset);
        final bool hasMoreVideos = moreVideos.length == 2;
        if (hasMoreVideos) {
          offset += 2;
        }
        final List<VideoContent> updatedVideos = List<VideoContent>.from(state.videos)..addAll(moreVideos);

        state = state.copyWith(videos: updatedVideos, isPaginating: false, hasMoreVideos: hasMoreVideos);

        // Preload new videos after loading more
        preloadNextVideos();
      }
    } catch (e) {
      state = state.copyWith(isPaginating: false, error: e);
    }
  }

  Future<void> preloadNextVideos() async {
    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;
    final videosToPreload = state.videos.skip(currentIndex + 1).take(2).map((v) => v.videoUrl).where((url) => !_preloadedFiles.containsKey(url));

    for (final videoUrl in videosToPreload) {
      if (!_preloadQueue.contains(videoUrl)) {
        _preloadQueue.add(videoUrl);
        _preloadVideo(videoUrl);
      }
    }
  }

  Future<void> _preloadVideo(String videoUrl) async {
    try {
      final file = await getCachedVideoFile(videoUrl);
      _preloadedFiles[videoUrl] = file;

      final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
      state = state.copyWith(preloadedVideoUrls: currentPreloaded);
    } catch (e) {
      debugPrint('Error preloading video: $e');
    } finally {
      _preloadQueue.remove(videoUrl);
    }
  }

  Future<File> getCachedVideoFile(String videoUrl) async {
    if (_preloadedFiles.containsKey(videoUrl)) {
      return _preloadedFiles[videoUrl]!;
    }

    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(videoUrl);
    final file = fileInfo?.file ?? await cacheManager.getSingleFile(videoUrl);

    _preloadedFiles[videoUrl] = file;
    return file;
  }

  void onPageChanged(int newIndex) async {
    state = state.copyWith(currentVideoIndex: newIndex);

    // Start preloading next videos
    preloadNextVideos();

    // Smart pagination trigger
    if (!_isPreloadingMore && state.hasMoreVideos && newIndex >= state.videos.length - 2) {
      _isPreloadingMore = true;
      await loadMoreVideos();
      _isPreloadingMore = false;
    }
  }

  FutureOr<void> dispose() {
    _preloadQueue.clear();
    _preloadedFiles.clear();
    return null;
  }

  File? getCachedFile(String videoUrl) {
    return _preloadedFiles[videoUrl];
  }
}
