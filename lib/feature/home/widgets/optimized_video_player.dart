import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OptimizedVideoPlayer extends HookConsumerWidget {
  const OptimizedVideoPlayer({
    super.key,
    required this.controller,
    required this.videoId,
  });

  final VideoPlayerController? controller;
  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Animation controller for loading indicator
    final loadingController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    final buffering = useState<bool>(false);
    final playing = useState<bool>(false);
    final playerKey = useState<Key>(UniqueKey());

    final previousController = useRef<VideoPlayerController?>(null);
    final previousVideoId = useRef<String?>(null);

    // Attach listener to controller
    useEffect(() {
      final current = controller;

      if (current == null) return null;

      void listener() {
        final isInitialized = current.value.isInitialized;
        final isBuffering = current.value.isBuffering;
        final isPlaying = current.value.isPlaying;
        final hasContent = current.value.position > Duration.zero && current.value.duration.inMilliseconds > 0;

        final shouldShowBuffering = isBuffering && !hasContent;

        if (buffering.value != shouldShowBuffering || playing.value != isPlaying) {
          buffering.value = shouldShowBuffering;
          playing.value = isPlaying;
        }

        // Trigger a rebuild when the controller is initialized
        if (isInitialized) {
          print('Controller is initialized for videoId: $videoId');
        }
      }

      current.addListener(listener);
      listener(); // Initial state update

      return () {
        current.removeListener(listener);
      };
    }, [
      controller,
      videoId
    ]);

    // Detect controller or video ID change
    useEffect(() {
      final changed = previousController.value != controller || previousVideoId.value != videoId;

      if (changed) {
        playerKey.value = UniqueKey();
        previousController.value = controller;
        previousVideoId.value = videoId;
      }

      return null;
    }, [
      controller,
      videoId
    ]);

    // Dispose animation controller
    useEffect(() {
      return () {
        loadingController.dispose();
      };
    }, []);

    // Ensure the controller is initialized before rendering the video
    if (controller == null || !controller!.value.isInitialized) {
      print('Controller is not initialized for videoId: $videoId');
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(loadingController),
          child: const CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        try {
          if (controller != null) {
            if (controller!.value.isPlaying) {
              await controller!.pause();
            } else {
              await controller!.play();
            }
          } else {
            debugPrint('Error: Controller is null for videoId $videoId');
          }
        } catch (e) {
          debugPrint('⚠️ Video play/pause error: $e');
        }
      },
      child: SizedBox.expand(
        child: FittedBox(
          key: playerKey.value,
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: Stack(
              children: [
                VideoPlayer(controller!),
                if (buffering.value)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
