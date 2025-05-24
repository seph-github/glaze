import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/home/models/glaze/glaze.dart';
import 'package:glaze/features/home/provider/video_feed_provider/video_feed_provider.dart';
import 'package:glaze/features/home/provider/videos_provider/videos_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../../../gen/assets.gen.dart';
import '../../dashboard/providers/dashboard_tab_controller_provider.dart';

import '../models/video_content/video_content.dart';
import '../provider/glaze_provider/glaze_provider.dart';
import '../widgets/video_player_component.dart';

class VideoFeedView extends HookConsumerWidget with WidgetsBindingObserver {
  const VideoFeedView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoFeedNotifierProvider);
    final appLifecycle = useAppLifecycleState();

    final userGlazes = useState<List<Glaze>>([]);

    const int maxCacheSize = 3;
    final currentPage = useState<int>(0);
    final isAppActive = useState<bool>(true);
    final controllerCache = useState<Map<String, VideoPlayerController>>({});
    final accessOrder = useState<List<String>>([]);
    final disposingControllers = useState<Set<String>>({});
    final PreloadPageController pageController = PreloadPageController(keepPage: false);

    final videos = ref.watch(videosProvider);
    final controllerCreationMap = useState<Map<String, Completer<VideoPlayerController>>>({});

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
      final tabIndex = ref.read(dashboardTabControllerProvider);

      if (controller != null && controller.value.isInitialized && !controller.value.isPlaying && tabIndex == 0) {
        try {
          await controller.play();
          if (controller.value.isPlaying) {}
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
      if (videos.isEmpty || currentPage.value >= videos.length) return;

      await pauseAllControllers();

      final videoId = videos[currentPage.value].id;
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
      if (videos.isEmpty) return;

      final windowStart = (currentPage - 1).clamp(0, videos.length - 1);
      final windowEnd = (currentPage + 1).clamp(0, videos.length - 1);

      final idsToKeep = <String>{};
      for (int i = windowStart; i <= windowEnd; i++) {
        if (i < videos.length) {
          idsToKeep.add(videos[i].id);
        }
      }

      final idsToDispose = controllerCache.value.keys.where((id) => !idsToKeep.contains(id)).toList();
      for (final id in idsToDispose) {
        await removeController(id);
      }

      if (currentPage < videos.length) {
        await getOrCreateController(videos[currentPage]);
        if (windowStart < currentPage && windowStart >= 0) {
          await getOrCreateController(videos[windowStart]);
        }
        if (windowEnd > currentPage && windowEnd < videos.length) {
          await getOrCreateController(videos[windowEnd]);
        }
      }
    }

    Future<void> handlePageChange(int newPage) async {
      if (videos.isEmpty || newPage >= videos.length) return;

      currentPage.value = newPage;

      await pauseAllControllers();

      try {
        await manageControllerWindow(newPage);

        if (videos.isNotEmpty && newPage < videos.length) {
          await initAndPlayVideo(newPage);
        }

        ref.read(videoFeedNotifierProvider.notifier).onPageChanged(newPage);
      } catch (e) {
        log('Handle page change error: $e');
      }
    }

    useEffect(
      () {
        WidgetsBinding.instance.addObserver(this);
        Future.microtask(
          () async {
            try {
              if (state.videos.isNotEmpty) {
                ref.read(videosProvider.notifier).setVideos(state.videos);
                await ref.read(glazeNotifierProvider.notifier).fetchUserGlazes();
                // WidgetsBinding.instance.addPostFrameCallback((_) async {
                await initAndPlayVideo(0);
                // });
              }
            } catch (e) {
              log('UseEffect catch error: $e');
            }
          },
        );

        return null;
      },
      [
        state.videos
      ],
    );

    useEffect(() {
      WidgetsBinding.instance.removeObserver(this);

      return () {
        disposeAllControllers();
      };
    }, []);

    useEffect(() {
      final currentLifecycle = appLifecycle;
      final wasPreviouslyActive = isAppActive.value;

      isAppActive.value = currentLifecycle == AppLifecycleState.resumed;

      final isNowActive = isAppActive.value;
      final dashboardIndex = ref.watch(dashboardTabControllerProvider);
      final currentPath = GoRouter.of(context).state.path;
      final isOnHomePage = currentPath == const HomeRoute().location;

      Future<void> handleLifecycleChange() async {
        if (isNowActive && !wasPreviouslyActive) {
          if (dashboardIndex != 0) {
            await pauseAllControllers();
            log('[VideoFeedView] Paused controllers (not on dashboard tab)');
          } else if (isOnHomePage) {
            await cleanupAndReinitializeCurrentVideo();
            log('[VideoFeedView] Reinitialized video (resumed on home tab)');
          }
        } else if (!isNowActive && wasPreviouslyActive) {
          await pauseAllControllers();
          log('[VideoFeedView] Paused controllers (app backgrounded)');
        }
      }

      Future.microtask(handleLifecycleChange);

      return null;
    }, [
      appLifecycle
    ]);

    ref.listen(
      videoFeedNotifierProvider,
      (prev, next) async {
        if (prev?.videos != next.videos || prev?.isLoading != next.isLoading || prev?.preloadedVideoUrls != next.preloadedVideoUrls) {
          ref.read(videosProvider.notifier).addVideos(next.videos);

          await initAndPlayVideo(0);
        }
      },
    );

    ref.listen(
      glazeNotifierProvider,
      (prev, next) {
        userGlazes.value = next.glazes ?? [];
      },
    );

    useEffect(() {
      final listener = ref.listenManual<int>(
        dashboardTabControllerProvider,
        (prev, next) async {
          final isActive = next == 0;

          final index = currentPage.value;
          final controller = getController(ref.watch(videosProvider).elementAtOrNull(index)?.id ?? '');

          if (controller != null && controller.value.isInitialized) {
            if (!isActive) {
              await controller.pause();

              await controller.seekTo(Duration.zero);
            } else {
              await controller.play();
            }
          }
        },
      );

      return listener.close;
    }, []);

    return RefreshIndicator(
      onRefresh: () async {
        await pauseAllControllers();
        await disposeAllControllers();

        await ref.read(videoFeedNotifierProvider.notifier).refreshVideos();

        currentPage.value = 0;
        await initAndPlayVideo(0);
      },
      color: Colors.white,
      child: RepaintBoundary(
        child: LoadingLayout(
          backgroundColor: ColorPallete.lightBackgroundColor,
          isLoading: state.isLoading,
          child: PreloadPageView.builder(
            preloadPagesCount: 2,
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
            onPageChanged: (index) => handlePageChange(index),
          ),
        ),
      ),
    );
  }
}
