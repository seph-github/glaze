import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../home/provider/video_feed_provider/video_feed_provider.dart';
import '../../home/widgets/video_player_component.dart';
import '../../templates/loading_layout.dart';
import '../providers/video_preview_provider/videos_preview_provider.dart';

class VideoPreviewView extends HookConsumerWidget with WidgetsBindingObserver {
  const VideoPreviewView({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  final List<VideoContent> videos;
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final appLifecycle = useAppLifecycleState();
    final isAppActive = useState<bool>(true);

    const int maxCacheSize = 3;

    final pageController = useMemoized(() {
      return PreloadPageController(initialPage: initialIndex);
    }, [
      initialIndex
    ]);

    final videos = ref.watch(videosPreviewProvider);
    final controllerCache = useState<Map<String, VideoPlayerController>>({});
    final disposingControllers = useState<Set<String>>({});
    final accessOrder = useState<List<String>>([]);
    final controllerCreationMap = useState<Map<String, Completer<VideoPlayerController>>>({});
    final currentPage = useState<int>(initialIndex);

    Future<void> pauseAllControllers() async {
      final controllers = List<VideoPlayerController>.from(controllerCache.value.values);

      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized && controller.value.isPlaying) {
            await controller.pause();

            await controller.seekTo(Duration.zero);
          }
        } catch (_) {}
      }
    }

    Future<void> removeController(String videoId) async {
      if (disposingControllers.value.contains(videoId)) return;

      disposingControllers.value.add(videoId);

      try {
        final controller = controllerCache.value[videoId];
        if (controller != null) {
          controllerCache.value.remove(videoId);
          accessOrder.value.remove(videoId);

          try {
            if (controller.value.isInitialized) {
              await controller.pause();

              await controller.seekTo(Duration.zero);
            }

            // await controller.dispose();
          } catch (_) {}
        }
      } catch (_) {
      } finally {
        disposingControllers.value.remove(videoId);
      }
    }

    void enforceCacheLimit() {
      while (controllerCache.value.length > maxCacheSize && accessOrder.value.isNotEmpty) {
        final oldestId = accessOrder.value.removeAt(0);

        removeController(oldestId);
      }
    }

    void touchController(String videoId) {
      accessOrder.value.remove(videoId);
      accessOrder.value.add(videoId);
    }

    Future<VideoPlayerController?> getOrCreateController(VideoContent video) async {
      if (controllerCache.value.containsKey(video.id)) {
        touchController(video.id);
        return controllerCache.value[video.id];
      }

      if (controllerCreationMap.value.containsKey(video.id)) {
        return await controllerCreationMap.value[video.id]!.future;
      }

      final completer = Completer<VideoPlayerController>();
      controllerCreationMap.value[video.id] = completer;

      try {
        final videoFile = await ref.watch(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);

        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();
        controller.setLooping(true);

        controllerCache.value[video.id] = controller;
        touchController(video.id);

        enforceCacheLimit();

        completer.complete(controller);
        return controller;
      } catch (e) {
        completer.completeError(e);
        return null;
      } finally {
        disposingControllers.value.remove(video.id);
        controllerCreationMap.value.remove(video.id);
      }
    }

    Future<void> playController(String videoId) async {
      final controller = controllerCache.value[videoId];

      if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
        try {
          await controller.play();
          if (controller.value.isPlaying) {}
        } catch (e) {
          log('Play controller error: $e');
        }
      }
    }

    Future<void> initAndPlayVideo(int index) async {
      if (this.videos.isEmpty || index >= this.videos.length) return;

      final video = this.videos[index];

      final controller = await getOrCreateController(video);

      if (controller != null) {
        while (!controller.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        if (index != currentPage.value) {
          return;
        }

        await playController(video.id);
      }
    }

    VideoPlayerController? getController(String videoId) {
      return controllerCache.value[videoId];
    }

    Future<void> cleanupAndReinitializeCurrentVideo() async {
      if (this.videos.isEmpty || currentPage.value >= this.videos.length) return;

      await pauseAllControllers();

      final videoId = this.videos[currentPage.value].id;
      final controller = getController(videoId);

      if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
        await removeController(videoId);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await initAndPlayVideo(currentPage.value);
    }

    Future<void> disposeAllControllers() async {
      pageController.dispose();

      final controllerIds = List<String>.from(controllerCache.value.keys);
      for (final id in controllerIds) {
        await removeController(id);
      }
      controllerCache.value.clear();
      accessOrder.value.clear();
    }

    Future<void> manageControllerWindow(int currentPage) async {
      if (this.videos.isEmpty) return;

      final windowStart = (currentPage - 1).clamp(0, this.videos.length - 1);
      final windowEnd = (currentPage + 1).clamp(0, this.videos.length - 1);

      final idsToKeep = <String>{};
      for (int i = windowStart; i <= windowEnd; i++) {
        if (i < this.videos.length) {
          idsToKeep.add(this.videos[i].id);
        }
      }

      final idsToDispose = controllerCache.value.keys.where((id) => !idsToKeep.contains(id)).toList();
      for (final id in idsToDispose) {
        await removeController(id);
      }

      if (currentPage < this.videos.length) {
        await getOrCreateController(this.videos[currentPage]);
        if (windowStart < currentPage && windowStart >= 0) {
          await getOrCreateController(this.videos[windowStart]);
        }
        if (windowEnd > currentPage && windowEnd < this.videos.length) {
          await getOrCreateController(this.videos[windowEnd]);
        }
      }
    }

    Future<void> handlePageChange(int newPage) async {
      if (this.videos.isEmpty || newPage >= this.videos.length) return;

      currentPage.value = newPage;

      await pauseAllControllers();

      try {
        await manageControllerWindow(newPage);

        if (this.videos.isNotEmpty && newPage < this.videos.length) {
          await initAndPlayVideo(newPage);
        }

        ref.read(videoFeedNotifierProvider.notifier).onPageChanged(newPage);
      } catch (_) {}
    }

    useEffect(() {
      WidgetsBinding.instance.addObserver(this);
      Future.microtask(
        () async {
          try {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              ref.read(videosPreviewProvider.notifier).setVideos(this.videos);

              await initAndPlayVideo(initialIndex);
            });
          } catch (e) {
            log('UseEffect catch error: $e');
          }
        },
      );
      return;
    }, [
      this.videos,
      initialIndex,
    ]);

    useEffect(() {
      Future.microtask(() {
        pageController.jumpToPage(initialIndex);
      });
      return null;
    }, []);

    useEffect(() {
      WidgetsBinding.instance.removeObserver(this);

      return () {
        disposeAllControllers();
      };
    }, []);

    useEffect(() {
      Future.microtask(() async {
        final state = appLifecycle;
        final wasActive = isAppActive.value;
        isAppActive.value = state == AppLifecycleState.resumed;
        final currentPath = router.state.path;

        print('preview page -- state: $state, was active: $wasActive, is app active: ${isAppActive.value}, route location: $currentPath');

        if (isAppActive.value && !wasActive) {
          print('preview page -- 1');
          await cleanupAndReinitializeCurrentVideo();
          // await pauseAllControllers();
        } else if (!isAppActive.value && wasActive) {
          print('preview page -- 2');
          await pauseAllControllers();
          // } else if (isAppActive.value && !wasActive && currentPath == '/video-preview') {
        } else {
          print('preview page -- 3');
          // await cleanupAndReinitializeCurrentVideo();
          await pauseAllControllers();
        }
      });

      return null;
    }, [
      appLifecycle
    ]);

    return SafeArea(
      top: false,
      child: LoadingLayout(
        backgroundColor: ColorPallete.lightBackgroundColor,
        appBar: AppBarWithBackButton(
          backgroundColor: Colors.transparent,
          onBackButtonPressed: () async {
            router.pop();
          },
        ),
        child: RepaintBoundary(
          child: PreloadPageView.builder(
            scrollDirection: Axis.vertical,
            controller: pageController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              if (index >= videos.length) return const SizedBox.shrink();
              final video = videos[index];

              if ((index - currentPage.value).abs() > 1) {
                return const SizedBox.shrink();
              }
              return FutureBuilder<VideoPlayerController?>(
                future: getOrCreateController(video),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          Assets.images.gif.donutLoading.path,
                        ),
                      ),
                    );
                  }
                  final controller = snapshot.data!;
                  final video = videos[index];

                  return VideoPlayerComponent(
                    controller: controller,
                    video: video,
                    currentActiveVideoId: videos[currentPage.value].id,
                  );
                },
              );
            },
            onPageChanged: (value) => handlePageChange(value),
          ),
        ),
      ),
    );
  }
}
