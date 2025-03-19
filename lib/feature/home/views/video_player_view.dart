import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:app_links/app_links.dart';

class VideoPlayerView extends HookWidget {
  const VideoPlayerView(
      {super.key, required this.url, required this.thumbnailUrl});

  final String url;
  final String thumbnailUrl;

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
  Widget build(BuildContext context) {
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final isError = useState(false);
    final showControls = useState(false);
    final hideControlsTimer = useState<Timer?>(null);
    final isThumbnailError = useState(false);

    useEffect(() {
      _preloadVideo(url, videoPlayerController, isError);

      // Example usage of AppLinks
      final appLinks = AppLinks();
      appLinks.getInitialLink().then((initialLink) {
        if (initialLink != null) {
          // Handle the initial link
          print('Initial link: $initialLink');
        }
      }).catchError((error) {
        print('Error getting initial link: $error');
      });

      return () {
        videoPlayerController.value?.dispose();
        hideControlsTimer.value?.cancel();
        isError.dispose(); // Dispose the isError notifier
      };
    }, [url]);

    void toggleControls() {
      showControls.value = !showControls.value;

      if (showControls.value) {
        hideControlsTimer.value?.cancel();
        hideControlsTimer.value = Timer(const Duration(seconds: 1), () {
          showControls.value = false;
        });
      }
    }

    void togglePlayPause() {
      if (videoPlayerController.value!.value.isPlaying) {
        videoPlayerController.value!.pause();
      } else {
        videoPlayerController.value!.play();
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
              child: VideoPlayer(videoPlayerController.value!),
            ),
            if (showControls.value)
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  videoPlayerController.value!.value.isPlaying
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
      return isThumbnailError.value
          ? const CircularProgressIndicator()
          : Image.network(
              thumbnailUrl,
              // errorBuilder: (context, error, stackTrace) {
              //   if (error is NetworkImageLoadException &&
              //       error.statusCode == 404) {
              //     WidgetsBinding.instance.addPostFrameCallback(
              //       (_) {
              //         isThumbnailError.value = true;
              //       },
              //     );
              //   }
              //   return const CircularProgressIndicator();
              // },
            );
    }

    return Scaffold(
      body: Center(
        child: isError.value
            ? const Text('Error loading video')
            : videoPlayerController.value != null &&
                    videoPlayerController.value!.value.isInitialized
                ? buildVideoPlayer()
                : buildThumbnail(),
      ),
    );
  }
}
