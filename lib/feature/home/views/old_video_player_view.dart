import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/video/video_model.dart';

class OldVideoPlayerView extends ConsumerWidget {
  const OldVideoPlayerView({super.key, required this.videoModel});

  final VideoModel videoModel;

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

  Future<void> _preloadVideo(
      String url,
      ValueNotifier<VideoPlayerController?> controllerNotifier,
      ValueNotifier<bool> isErrorNotifier) async {
    try {
      final config = Config(
        'customCacheKey',
        stalePeriod: const Duration(hours: 6),
        maxNrOfCacheObjects: 20,
      );

      final cacheManager = CacheManager(config);

      File file = await cacheManager.getSingleFile(url);
      file = await _ensureMp4Extension(file);
      file = await _moveToTemporaryDirectory(file);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true); // Set the video to loop

      controllerNotifier.value = controller;
      controller.play();
    } catch (e) {
      isErrorNotifier.value = true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayerController = ref.watch(videoPlayerControllerProvider);
    final isError = ref.watch(isErrorProvider);
    final showControls = ref.watch(showControlsProvider);
    final hideControlsTimer = ref.watch(hideControlsTimerProvider);
    final isThumbnailError = ref.watch(isThumbnailErrorProvider);

    ref.listen(
      videoPlayerControllerProvider,
      (previous, next) {
        if (previous != next) {
          _preloadVideo(
            videoModel.videoUrl,
            ValueNotifier(videoPlayerController),
            ValueNotifier(isError),
          );
        }
      },
    );

    void toggleControls() {
      ref.read(showControlsProvider.notifier).state = !showControls;

      if (showControls) {
        hideControlsTimer?.cancel();
        ref.read(hideControlsTimerProvider.notifier).state =
            Timer(const Duration(seconds: 1), () {
          ref.read(showControlsProvider.notifier).state = false;
        });
      }
    }

    void togglePlayPause() {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController.pause();
      } else {
        videoPlayerController.play();
      }
    }

    Widget buildVideoPlayer() {
      return GestureDetector(
        onTap: () {
          toggleControls();
          togglePlayPause();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 9 / 19.5,
              child: VideoPlayer(
                videoPlayerController!,
              ),
            ),
            if (showControls)
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  videoPlayerController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
          ],
        ),
      );
    }

    Widget buildThumbnail() {
      return isThumbnailError
          ? const CircularProgressIndicator()
          : Image.network(
              videoModel.thumbnailUrl,
              errorBuilder: (context, error, stackTrace) {
                if (error is NetworkImageLoadException &&
                    error.statusCode == 404) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      // isThumbnailError.value = true;
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            );
    }

    return Scaffold(
      body: Center(
        child: isError
            ? const Text('Error loading video')
            : videoPlayerController != null &&
                    videoPlayerController.value.isInitialized
                ? buildVideoPlayer()
                : buildThumbnail(),
      ),
    );
  }
}

final videoPlayerControllerProvider = StateNotifierProvider<
    VideoPlayerControllerNotifier, VideoPlayerController?>((ref) {
  return VideoPlayerControllerNotifier();
});

final isErrorProvider = StateProvider<bool>((ref) => false);
final showControlsProvider = StateProvider<bool>((ref) => false);
final hideControlsTimerProvider = StateProvider<Timer?>((ref) => null);
final isThumbnailErrorProvider = StateProvider<bool>((ref) => false);

class VideoPlayerControllerNotifier
    extends StateNotifier<VideoPlayerController?> {
  VideoPlayerControllerNotifier() : super(null);

  void setController(VideoPlayerController controller) {
    state = controller;
  }

  void disposeController() {
    state?.dispose();
    state = null;
  }
}
