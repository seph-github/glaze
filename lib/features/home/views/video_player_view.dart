import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

import '../../../gen/assets.gen.dart';
import '../../../utils/video_feed_sharing_popup.dart';
import '../provider/glaze_provider/glaze_provider.dart';
import '../provider/videos_provider/videos_provider.dart';
import '../widgets/home_interactive_card.dart';

class VideoPlayerView extends HookWidget {
  const VideoPlayerView({
    super.key,
    required this.controller,
    required this.video,
  });

  final VideoPlayerController controller;

  final VideoContent video;

  @override
  Widget build(BuildContext context) {
    final showIcon = useState<bool>(false);
    final showMoreDonutOptions = useState<bool>(false);

    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);
    Timer? timer;

    void startHideTimer() {
      timer?.cancel();
      timer = Timer(
        const Duration(milliseconds: 1500),
        () {
          showIcon.value = false;
        },
      );
    }

    void toggleDonutOptions(bool value) {
      showMoreDonutOptions.value = value;
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
          if (controller.value.size.height > 640)
            VideoPlayer(controller)
          else
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          if (showIcon.value)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
              ),
              child: SvgPicture.asset(Assets.images.svg.playIcon.path, height: 24.0),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, _) {
                return HomeInteractiveCard(
                  key: PageStorageKey('HomeInteractiveCard_${video.id}'),
                  onGlazeLongPress: () => toggleDonutOptions(true),
                  controller: controller,
                  glazeCount: video.glazesCount ?? 0,
                  isGlazed: video.hasGlazed,
                  onGlazeTap: () async {
                    final isCurrentlyGlazed = video.hasGlazed;
                    final newGlazeCount = isCurrentlyGlazed ? (video.glazesCount ?? 0) - 1 : (video.glazesCount ?? 0) + 1;

                    ref.read(videosProvider.notifier).updateVideo(video.id, newGlazeCount, !isCurrentlyGlazed);

                    await ref.read(glazeNotifierProvider.notifier).onGlazed(videoId: video.id);
                  },
                  onShareTap: () async => await showShareOptions(context),
                  width: width,
                  height: height,
                  video: video,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
