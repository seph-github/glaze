import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

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
    final playerKey = useState<Key>(UniqueKey());
    final previousVideoId = useRef<String?>(null);

    // React to video ID change
    useEffect(() {
      print('calling use effect 1');
      if (previousVideoId.value != videoId) {
        playerKey.value = UniqueKey();
        previousVideoId.value = videoId;
      }
      return null;
    }, [
      videoId
    ]);

    // AnimationController — using hook-safe setup
    final spinnerController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Safely auto-dispose on unmount
    useEffect(() {
      print('calling use effect 2');
      return () {
        if (spinnerController.isAnimating) {
          spinnerController.stop();
        }
      };
    }, [
      spinnerController
    ]);

    if (controller == null || !controller!.value.isInitialized) {
      print('calling use effect 3');
      if (kDebugMode) {
        print('calling use effect 4');
        dev.log('Controller not ready: $videoId', name: 'OptimizedVideoPlayer');
      }

      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(spinnerController),
          child: const CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final value = useListenable(controller);
    final isBuffering = value!.value.isBuffering;
    final isPlaying = value.value.isPlaying;

    final onTap = useCallback(() async {
      print('calling use effect 5');
      try {
        print('calling use effect 6');
        if (controller!.value.isInitialized) {
          print('calling use effect 7');
          isPlaying ? await controller!.pause() : await controller!.play();
        }
      } catch (e) {
        print('calling use effect 8');
        dev.log('Video play/pause error: $e', name: 'OptimizedVideoPlayer');
      }
    }, [
      controller,
      isPlaying
    ]);

    print('rebuilt');
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand(
        child: FittedBox(
          key: playerKey.value,
          fit: BoxFit.cover,
          child: SizedBox(
            width: value.value.size.width,
            height: value.value.size.height,
            child: Stack(
              children: [
                VideoPlayer(controller!),
                if (isBuffering)
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
