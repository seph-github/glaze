// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:glaze/feature/video/widget/video_feed_item.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:preload_page_view/preload_page_view.dart';
// import 'package:video_player/video_player.dart';

// // import 'provider/video_feed_controller.dart';

// class VideoFeedView extends HookConsumerWidget {
//   const VideoFeedView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final videoFeedState = ref.watch(videoFeedControllerProvider);
//     // final videoFeedNotifier = ref.read(videoFeedControllerProvider.notifier);

//     final pageController = useMemoized(() => PreloadPageController(), []);
//     final currentPage = useState(0);

//     // Initialize videos when the widget is first built
//     useEffect(() {
//       // videoFeedNotifier.initializeVideos();
//       return null; // No cleanup needed
//     }, []);

//     // Handle app lifecycle changes
//     // useAppLifecycleObserver(
//     //   // onResumed: () => videoFeedNotifier.cleanupAndReinitializeCurrentVideo(currentPage.value),
//     //   // onPaused: () => videoFeedNotifier.pauseAllControllers(),
//     // );

//     void handlePageChange(int index) {
//       currentPage.value = index;
//       // videoFeedNotifier.handlePageChange(index);
//     }

//     return RepaintBoundary(
//       child: PreloadPageView.builder(
//         scrollDirection: Axis.vertical,
//         controller: pageController,
//         itemCount: videoFeedState.videos.length,
//         physics: const AlwaysScrollableScrollPhysics(),
//         onPageChanged: handlePageChange,
//         itemBuilder: (context, index) {
//           final video = videoFeedState.videos[index];
//           final controller = ref.watch(videoControllerProvider(video.id));

//           return RepaintBoundary(
//             child: VideoFeedItem(
//               key: ValueKey(video.id),
//               controller: controller,
//               videoItem: video,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// void useAppLifecycleObserver({
//   required VoidCallback onResumed,
//   required VoidCallback onPaused,
// }) {
//   useEffect(() {
//     final observer = _AppLifecycleObserver(onResumed: onResumed, onPaused: onPaused);
//     WidgetsBinding.instance.addObserver(observer);

//     return () => WidgetsBinding.instance.removeObserver(observer);
//   }, []);
// }

// class _AppLifecycleObserver extends WidgetsBindingObserver {
//   final VoidCallback onResumed;
//   final VoidCallback onPaused;

//   _AppLifecycleObserver({required this.onResumed, required this.onPaused});

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       onResumed();
//     } else if (state == AppLifecycleState.paused) {
//       onPaused();
//     }
//   }
// }
