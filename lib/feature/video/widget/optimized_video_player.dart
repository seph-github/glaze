import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatelessWidget {
  const OptimizedVideoPlayer({
    super.key,
    this.controller,
    required this.videoId,
  });

  final VideoPlayerController? controller;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    // bool isBuffering = false;

    return GestureDetector(
      onTap: () {},
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller?.value.size.width,
            height: controller?.value.size.height,
            child: Stack(
              children: [
                VideoPlayer(controller!),
                // if (isBuffering) const Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
