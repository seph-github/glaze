import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

import '../../../gen/assets.gen.dart';

class VideoPlayerView extends HookWidget {
  const VideoPlayerView({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final showIcon = useState<bool>(false);
    Timer? timer;

    void startHideTimer() {
      timer?.cancel();
      timer = Timer(
        const Duration(seconds: 3),
        () {
          showIcon.value = false;
        },
      );
    }

    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
        showIcon.value = true;
        startHideTimer();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(
            controller,
          ),
          if (showIcon.value)
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
              ),
              child: controller.value.isPlaying
                  ? const Icon(Icons.pause)
                  : SvgPicture.asset(Assets.images.svg.playIcon.path,
                      height: 24.0),
            ),
        ],
      ),
    );
  }
}
