import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/home/models/glaze/glaze.dart';
import 'package:glaze/feature/home/provider/video_feed_provider.dart';
import 'package:glaze/feature/home/provider/videos_provider/videos_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../../../components/morphism_widget.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../dashboard/providers/dashboard_tab_controller_provider.dart';

import '../models/video_content/video_content.dart';
import '../provider/glaze_provider.dart';
import '../widgets/home_interactive_card.dart';
import '../widgets/share_option_button.dart';

class VideoFeedView extends HookConsumerWidget with WidgetsBindingObserver {
  const VideoFeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoFeedNotifierProvider);
    final appLifecycle = useAppLifecycleState();
    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);
    final showMoreDonutOptions = useState<bool>(false);
    final userGlazes = useState<List<Glaze>>([]);

    const int maxCacheSize = 3;
    final currentPage = useState<int>(0);
    final isAppActive = useState<bool>(true);
    final controllerCache = useState<Map<String, VideoPlayerController>>({});
    final accessOrder = useState<List<String>>([]);
    final disposingControllers = useState<Set<String>>({});
    final PreloadPageController pageController = PreloadPageController();
    final showPlayIcon = useState<bool>(false);

    // final videos = useState<List<VideoContent>>([]);
    final videos = ref.watch(videosProvider);
    final controllerCreationMap = useState<Map<String, Completer<VideoPlayerController>>>({});

    void toggleDonutOptions(bool value) {
      showMoreDonutOptions.value = value;
    }

    /// Pause all controllers
    Future<void> pauseAllControllers() async {
      final controllers = List<VideoPlayerController>.from(controllerCache.value.values);

      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized && controller.value.isPlaying) {
            await controller.pause();
            await controller.seekTo(Duration.zero); // Reset to the beginning
          }
        } catch (e) {
          log('Pause all controllers error: $e');
        }
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
          // Remove from cache immediately
          controllerCache.value.remove(videoId);
          accessOrder.value.remove(videoId);

          // Pause and dispose
          try {
            if (controller.value.isInitialized) {
              await controller.pause();
            }

            await controller.dispose();
          } catch (e) {
            log('Remove controller 1st catch error: $e');
          }
        } else {}
      } catch (e) {
        log('Remove controller 2nd catch error: $e');
      } finally {
        disposingControllers.value.remove(videoId);
      }
    }

    /// Enforce the cache size limit by removing least recently used controllers
    void enforceCacheLimit() {
      while (controllerCache.value.length > maxCacheSize && accessOrder.value.isNotEmpty) {
        final oldestId = accessOrder.value.removeAt(0); // Remove the least recently used ID

        removeController(oldestId); // Dispose of the corresponding controller
      }
    }

    /// Touch a controller to mark it as recently used
    void touchController(String videoId) {
      accessOrder.value.remove(videoId); // Remove if it exists
      accessOrder.value.add(videoId); // Add to the end to mark as recently used
    }

    /// Get or create a controller for a video
    Future<VideoPlayerController?> getOrCreateController(VideoContent video) async {
      // Check if the controller already exists in the cache
      if (controllerCache.value.containsKey(video.id)) {
        touchController(video.id); // Mark as recently used
        return controllerCache.value[video.id];
      }

      // Check if a controller creation process is already in progress
      if (controllerCreationMap.value.containsKey(video.id)) {
        return await controllerCreationMap.value[video.id]!.future;
      }

      // Start the controller creation process
      final completer = Completer<VideoPlayerController>();
      controllerCreationMap.value[video.id] = completer;

      try {
        final videoFile = await ref.watch(videoFeedNotifierProvider.notifier).getCachedVideoFile(video.videoUrl);

        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();
        controller.setLooping(true);

        controllerCache.value[video.id] = controller; // Add to cache
        touchController(video.id); // Update access order

        enforceCacheLimit(); // Ensure cache size limit

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

    /// Play a controller if it exists and is initialized
    Future<void> playController(String videoId) async {
      final controller = controllerCache.value[videoId];
      if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
        try {
          await controller.play();
        } catch (e) {
          log('Play controller error: $e');
        }
      }
    }

    /// Initialize and play a video at the given index
    Future<void> initAndPlayVideo(int index) async {
      if (videos.isEmpty || index >= videos.length) return;

      final video = videos[index];

      final controller = await getOrCreateController(video);

      if (controller != null) {
        // Wait for the controller to be fully initialized
        while (!controller.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        if (index != currentPage.value) {
          return;
        }

        await playController(video.id);
      }
    }

    /// Get a controller for a video ID if it exists in the cache
    VideoPlayerController? getController(String videoId) {
      return controllerCache.value[videoId];
    }

    /// Clean up and reinitialize the current video when coming back from background
    Future<void> cleanupAndReinitializeCurrentVideo() async {
      if (videos.isEmpty || currentPage.value >= videos.length) return;

      await pauseAllControllers();

      final videoId = videos[currentPage.value].id;
      final controller = getController(videoId);

      // If controller exists but has errors, dispose it
      if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
        await removeController(videoId);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Reinitialize and play current video
      await initAndPlayVideo(currentPage.value);
    }

    /// Dispose all controllers
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

    /// Handle page changes in the video feed
    Future<void> handlePageChange(int newPage) async {
      if (videos.isEmpty || newPage >= videos.length) return;

      currentPage.value = newPage;

      // Pause all videos to ensure only the current video plays
      await pauseAllControllers();

      try {
        // Manage the window controllers
        await manageControllerWindow(newPage);

        // Play only the current video
        if (videos.isNotEmpty && newPage < videos.length) {
          await initAndPlayVideo(newPage);
        }

        // Notify the cubit
        ref.read(videoFeedNotifierProvider.notifier).onPageChanged(newPage);
      } catch (e) {
        log('Handle page change error: $e');
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addObserver(this);
      Future.microtask(
        () async {
          try {
            await ref.read(glazeNotifierProvider.notifier).fetchUserGlazes();
            ref.watch(videoFeedNotifierProvider);
            if (state.videos.isNotEmpty) {
              // videos = state.videos;
              ref.read(videosProvider.notifier).setVideos(state.videos);
              await initAndPlayVideo(0);
            }
          } catch (e) {
            log('UseEffect catch error: $e');
          }
        },
      );
      return null;
    }, [
      state.videos
    ]);

    useEffect(() {
      WidgetsBinding.instance.removeObserver(this);

      return () {
        disposeAllControllers();
      };
    }, []);

    useEffect(() {
      final state = appLifecycle;

      final wasActive = isAppActive.value;
      isAppActive.value = state == AppLifecycleState.resumed;
      final dashboardIndex = ref.watch(dashboardTabControllerProvider);
      if (isAppActive.value && !wasActive) {
        if (dashboardIndex != 0) {
          pauseAllControllers();
        } else {
          cleanupAndReinitializeCurrentVideo();
        }
      } else if (!isAppActive.value && wasActive) {
        // App is going to background - pause all videos
        pauseAllControllers();
      }
      return null;
    }, [
      appLifecycle
    ]);

    ref.listen(
      videoFeedNotifierProvider,
      (prev, next) {
        if (prev?.videos != next.videos || prev?.isLoading != next.isLoading || prev?.preloadedVideoUrls != next.preloadedVideoUrls) {
          // videos.value = next.videos;
          ref.read(videosProvider.notifier).addVideos(next.videos);
          manageControllerWindow(currentPage.value);
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
          log('isActive = $isActive');
          final index = currentPage.value;
          final controller = getController(ref.watch(videosProvider).elementAtOrNull(index)?.id ?? '');

          if (controller != null && controller.value.isInitialized) {
            if (!isActive) {
              await controller.pause();
              debugPrint('⏸ Paused video (not on Home tab)');
            } else {
              await controller.play();
              debugPrint('▶️ Resumed video (back to Home tab)');
            }
          }
        },
      );

      return listener.close;
    }, []);

    return RefreshIndicator(
      onRefresh: () async {
        // Pause all current playing videos
        await pauseAllControllers();

        // Fetch new videos
        await ref.read(videoFeedNotifierProvider.notifier).refreshVideos();

        // Reset and play top video
        currentPage.value = 0;
        await initAndPlayVideo(0);
      },
      color: Colors.white,
      child: RepaintBoundary(
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[currentPage.value];

            if ((index - currentPage.value).abs() > 1) return const SizedBox.shrink();

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
                        if (!(index == currentPage.value)) return;

                        if (controller.value.isPlaying) {
                          showPlayIcon.value = false;
                          await controller.pause();
                        } else {
                          showPlayIcon.value = true;
                          await controller.play();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(controller),
                          if (!controller.value.isPlaying && !showPlayIcon.value)
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
                      child: HomeInteractiveCard(
                        key: PageStorageKey('HomeInteractiveCard_${currentPage.value}'),
                        onGlazeLongPress: () => toggleDonutOptions(true),
                        controller: getController(videos[currentPage.value].id),
                        glazeCount: videos[currentPage.value].glazesCount ?? 0,
                        isGlazed: videos[currentPage.value].hasGlazed,
                        onGlazeTap: () async {
                          final isCurrentlyGlazed = video.hasGlazed;
                          final newGlazeCount = isCurrentlyGlazed ? (video.glazesCount ?? 0) - 1 : (video.glazesCount ?? 0) + 1;

                          // Update the video state globally
                          ref.read(videosProvider.notifier).updateVideo(video.id, newGlazeCount, !isCurrentlyGlazed);

                          // Optionally, make an API call to persist the change

                          // Call API to glaze
                          await ref.read(glazeNotifierProvider.notifier).onGlazed(videoId: video.id);
                        },
                        // isGlazed: userGlazes.value.any(
                        //   (glaze) {
                        //     return glaze.videoId == videos.value[index].id;
                        //   },
                        // ),
                        // onGlazeTap: () async {
                        //   await ref.read(glazeNotifierProvider.notifier).onGlazed(videoId: videos.value[index].id).then(
                        //         (_) => ref.refresh(glazeNotifierProvider.notifier).fetchUserGlazes(),
                        //       );
                        // },
                        onShareTap: () async => await _showShareOptions(context),
                        width: width,
                        height: height,
                        video: videos[currentPage.value],
                      ),
                    ),
                  ],
                );
                //   },
                // );
              },
            );
          },
          onPageChanged: (index) => handlePageChange(index),
        ),
      ),
    );
  }

  Future<void> _showShareOptions(
    BuildContext ctx,
  ) async {
    return await showDialog(
      context: ctx,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 430.0,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.0),
              image: DecorationImage(
                image: AssetImage(
                  Assets.images.png.glazeCardBackgroundR32.path,
                ),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: MorphismWidget.circle(
                    onTap: () {
                      ctx.pop();
                    },
                    size: 28.0,
                    child: SvgPicture.asset(
                      Assets.images.svg.closeIcon.path,
                    ),
                  ),
                ),
                MorphismWidget.circle(
                  size: 64.0,
                  child: SvgPicture.asset(Assets.images.svg.shareIcon.path),
                ),
                Text(
                  'Upload Your Moment',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'Share your talent with the community!',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ColorPallete.hintTextColor,
                      ),
                ),
                const Gap(20),
                Divider(
                  color: ColorPallete.whiteSmoke.withValues(alpha: 0.1),
                  thickness: 0.5,
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share with others',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ColorPallete.hintTextColor,
                        ),
                  ),
                ),
                const Spacer(),
                Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 30.0,
                  spacing: 60.0,
                  children: [
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.copyLinkIcon.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.emailSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.twitterSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.whatsappSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.snapchatSocialMedia.path),
                    ),
                    ShareOptionButton(
                      child: SvgPicture.asset(Assets.images.svg.tikTokSocialMedia.path),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
