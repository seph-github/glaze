import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/assets.gen.dart';
import '../../../utils/video_feed_sharing_popup.dart';
import '../../dashboard/providers/dashboard_tab_controller_provider.dart';
import '../../home/provider/glaze_provider.dart';
import '../../home/provider/video_feed_provider.dart';
import '../../home/provider/videos_provider/videos_provider.dart';
import '../../home/widgets/home_interactive_card.dart';
import '../../templates/loading_layout.dart';

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

    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);

    const int maxCacheSize = 3;
    final showPlayerIcon = useState<bool>(false);
    final PreloadPageController pageController = PreloadPageController(
      initialPage: initialIndex,
    );

    final videos = ref.watch(videosProvider);
    final controllerCache = useState<Map<String, VideoPlayerController>>({});
    final disposingControllers = useState<Set<String>>({});
    final accessOrder = useState<List<String>>([]);
    final controllerCreationMap = useState<Map<String, Completer<VideoPlayerController>>>({});
    final currentPage = useState<int>(pageController.initialPage);
    final showPlayIcon = useState<bool>(true);

    // final userGlazes = useState<List<Glaze>>([]);

    Future<void> pauseAllControllers() async {
      final controllers = List<VideoPlayerController>.from(controllerCache.value.values);

      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized && controller.value.isPlaying) {
            await controller.pause();
            showPlayIcon.value = true;
            await controller.seekTo(Duration.zero);
          }
        } catch (_) {}
      }
    }

    Future<void> removeController(String videoId) async {
      if (disposingControllers.value.contains(videoId)) {
        return;
      }

      disposingControllers.value.add(videoId);

      try {
        final controller = controllerCache.value[videoId];
        if (controller != null) {
          controllerCache.value.remove(videoId);
          accessOrder.value.remove(videoId);

          try {
            if (controller.value.isInitialized) {
              await controller.pause();
              showPlayIcon.value = true;
            }

            await controller.dispose();
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
        final videoFile = await ref.read(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);

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

      final tabIndex = ref.watch(dashboardTabControllerProvider);
      if (controller != null && controller.value.isInitialized && !controller.value.isPlaying && tabIndex == 1) {
        try {
          await controller.play();
        } catch (_) {}
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
      Future.microtask(() async {
        ref.read(videosProvider.notifier).setVideos(this.videos);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          initAndPlayVideo(initialIndex);
        });
      });
      return;
    }, [
      this.videos,
      initialIndex,
    ]);

    useEffect(() {
      WidgetsBinding.instance.removeObserver(this);

      return () {
        disposeAllControllers();
      };
    }, []);

    useEffect(() {
      final listener = ref.listenManual<int>(
        dashboardTabControllerProvider,
        (prev, next) async {
          final isActive = next == 1;

          if (!isActive) {
            // Pop this page if the user switches away from tab 1

            router.pop();

            return;
          }

          final index = currentPage.value;
          final controller = getController(this.videos[index].id);

          if (controller != null && controller.value.isInitialized) {
            if (!isActive) {
              await controller.pause();
              showPlayIcon.value = false;
            } else {
              await controller.play();
              showPlayIcon.value = true;
            }
          }
        },
      );

      return listener.close;
    }, []);

    useEffect(() {
      Future.microtask(() async {
        final state = appLifecycle;
        final wasActive = isAppActive.value;
        isAppActive.value = state == AppLifecycleState.resumed;

        final dashboardIndex = ref.read(dashboardTabControllerProvider);

        if (isAppActive.value && !wasActive) {
          if (dashboardIndex != 1) {
            await pauseAllControllers();
          } else {
            await cleanupAndReinitializeCurrentVideo();
          }
        } else if (!isAppActive.value && wasActive) {
          await pauseAllControllers();
        }
      });

      return null;
    }, [
      appLifecycle
    ]);

    useEffect(() {
      final listener = ref.listenManual<int>(
        dashboardTabControllerProvider,
        (prev, next) async {
          final isActive = next == 1;

          final index = currentPage.value;
          final controller = getController(this.videos[index].id);

          if (controller != null && controller.value.isInitialized) {
            if (!isActive) {
              await controller.pause();
              showPlayIcon.value = false;
            } else {
              await controller.play();
              showPlayIcon.value = true;
            }
          }
        },
      );

      return listener.close;
    }, []);

    return LoadingLayout(
      appBar: AppBarWithBackButton(
        onBackButtonPressed: () async {
          router.pop();
        },
      ),
      child: RepaintBoundary(
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: this.videos.length,
          itemBuilder: (context, index) {
            if (index < 0 || index >= videos.length) return const SizedBox.shrink();

            if ((index - currentPage.value).abs() > 1) return const SizedBox.shrink();

            final video = videos[index];

            return FutureBuilder<VideoPlayerController?>(
              future: getOrCreateController(video),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final controller = snapshot.data!;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!(index == currentPage.value)) {
                          return;
                        } else if (controller.value.isPlaying) {
                          await controller.pause();
                          showPlayerIcon.value = true;
                        } else {
                          await controller.play();
                          showPlayerIcon.value = false;
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(
                            controller,
                          ),
                          if (showPlayerIcon.value)
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: Center(
                                child: SvgPicture.asset(Assets.images.svg.playIcon.path),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: HomeInteractiveCard(
                          key: PageStorageKey('HomeInteractiveCard_$index'),
                          video: video,
                          width: width,
                          height: height,
                          controller: getController(video.id),
                          glazeCount: videos[index].glazesCount ?? 0,
                          isGlazed: videos[index].hasGlazed,
                          onGlazeTap: () async {
                            final isCurrentlyGlazed = video.hasGlazed;
                            final newGlazeCount = isCurrentlyGlazed ? (video.glazesCount ?? 0) - 1 : (video.glazesCount ?? 0) + 1;

                            ref.read(videosProvider.notifier).updateVideo(video.id, newGlazeCount, !isCurrentlyGlazed);

                            await ref.read(glazeNotifierProvider.notifier).onGlazed(videoId: video.id);
                          },
                          onShareTap: () async => await showShareOptions(context),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
          onPageChanged: (value) => handlePageChange(value),
        ),
      ),
    );
  }
}
