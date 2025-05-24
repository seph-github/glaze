import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:glaze/features/home/widgets/optimized_video_player.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/video_feed_sharing_popup.dart';
import '../provider/glaze_provider/glaze_provider.dart';
import '../provider/videos_provider/videos_provider.dart';
import 'home_interactive_card.dart';

class VideoPlayerComponent extends HookWidget {
  const VideoPlayerComponent({
    super.key,
    required this.controller,
    required this.video,
    required this.currentActiveVideoId,
  });

  final VideoPlayerController controller;

  final VideoContent video;
  final String currentActiveVideoId;

  @override
  Widget build(BuildContext context) {
    final showMoreDonutOptions = useState<bool>(false);

    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);

    void toggleDonutOptions(bool value) {
      showMoreDonutOptions.value = value;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        OptimizedVideoPlayer(
          controller: controller,
          videoId: video.id,
          currentActiveVideoId: currentActiveVideoId,
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
    );
  }
}
