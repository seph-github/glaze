// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:glaze/feature/home/services/video_content_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

import '../../models/cached_video_content/cached_video_content.dart';

part 'video_content_provider.freezed.dart';
part 'video_content_provider.g.dart';

@freezed
abstract class VideoContentState with _$VideoContentState {
  const factory VideoContentState({
    @Default(null) String? response,
    @Default(null) CachedVideoContent? cachedVideoContent,
    @Default([]) List<VideoContent> videoContents,
    @Default(false) bool isLoading,
    @Default(null) Exception? error,
  }) = _VideoContentState;

  const VideoContentState._();
}

@riverpod
class VideoContentNotifier extends _$VideoContentNotifier {
  @override
  VideoContentState build() {
    Future.microtask(() async => await fetchVideoContents());
    return const VideoContentState();
  }

  void _setNewResponse(String response) {
    state = state.copyWith(isLoading: false, response: null);
    state = state.copyWith(isLoading: false, response: response);
  }

  void _setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<List<dynamic>> _cachingVideos(List<VideoContent> videoContents) async {
    List<Config> config = List.generate(
      videoContents.length,
      (index) => Config(
        videoContents[index].videoUrl,
        stalePeriod: const Duration(hours: 6),
        maxNrOfCacheObjects: 20,
      ),
    )
        .map(
          (e) => e,
        )
        .toList();

    final List<CacheManager> cacheManager = config.map((cache) => CacheManager(cache)).toList();

    final List<VideoPlayerController> controllers = List.generate(cacheManager.length, (index) => VideoPlayerController.file(File('')), growable: true);

    for (int index = 0; index < cacheManager.length; index++) {
      final List<File> files = List.generate(
        cacheManager.length,
        (index) => File(''),
      );
      files[index] = await cacheManager[index].getSingleFile(videoContents[index].videoUrl);

      files[index] = await _ensureMp4Extension(files[index]);
      files[index] = await _moveToTemporaryDirectory(files[index]);

      controllers[index] = VideoPlayerController.file(files[index]);

      await controllers[index].initialize();
      controllers[index].setLooping(true);

      if (index == 0) {
        controllers[index].play();
      } else {
        controllers[index].pause();
      }
    }
    return controllers;
  }

  Future<void> fetchVideoContents() async {
    state = state.copyWith(isLoading: true);
    try {
      final videoContents = await VideoContentServices().fetchAllVideos();
      if (videoContents.isEmpty) {
        state = state.copyWith(isLoading: false, error: Exception('No video contents found'));
        return;
      }

      // final controllers = await _cachingVideos(videoContents);

      // final updatedVideoContents = [
      //   ...state.videoContents,
      //   ...videoContents
      // ];
      // final updatedControllers = [
      //   ...?state.cachedVideoContent?.controllers,
      //   ...controllers
      // ];

      state = state.copyWith(
          videoContents: videoContents,
          // cachedVideoContent: CachedVideoContent(
          //   videoContents: updatedVideoContents,
          //   controllers: updatedControllers,
          // ),
          isLoading: false);
    } catch (e) {
      _setError(e);
    }
  }

  Future<File> _ensureMp4Extension(File file) async {
    if (!file.path.toLowerCase().endsWith('.mp4')) {
      final newPath = "${file.path}.mp4";
      final newFile = await file.copy(newPath);
      return newFile;
    }
    return file;
  }

  Future<File> _moveToTemporaryDirectory(File file) async {
    final tempDir = await getTemporaryDirectory();
    final newPath = "${tempDir.path}/${file.uri.pathSegments.last}";

    return file.copy(newPath);
  }
}
