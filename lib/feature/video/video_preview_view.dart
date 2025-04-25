import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/home/models/glaze/glaze.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:glaze/feature/home/widgets/home_interactive_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../gen/assets.gen.dart';
import '../home/provider/glaze_provider.dart';
import '../templates/loading_layout.dart';

class VideoPreviewView extends HookConsumerWidget {
  const VideoPreviewView({
    super.key,
    required this.video,
  });

  final VideoContent video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);
    final controller = useState<VideoPlayerController>(
      VideoPlayerController.networkUrl(
        Uri.parse(video.videoUrl),
      ),
    );

    final isInitialized = useState(false);
    final showPlayerIcon = useState<bool>(false);
    final userGlazes = useState<List<Glaze>>([]);

    useEffect(() {
      controller.value.initialize().then((_) async {
        isInitialized.value = true;
        await ref.read(glazeNotifierProvider.notifier).getVideoGlazeStats(video.id);

        await controller.value.play();
        await controller.value.setLooping(true);
      });

      return controller.value.dispose;
    }, []);

    ref.listen(
      glazeNotifierProvider,
      (prev, next) {
        userGlazes.value = next.glazes ?? [];
      },
    );

    return LoadingLayout(
      isLoading: !isInitialized.value,
      appBar: const AppBarWithBackButton(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              if (controller.value.value.isPlaying) {
                await controller.value.pause();
                showPlayerIcon.value = true;
              } else {
                await controller.value.play();
                showPlayerIcon.value = false;
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(
                  controller.value,
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
                video: video,
                width: width,
                height: height,
                glazeCount: ref.watch(glazeNotifierProvider).stats.count,
                isGlazed: ref.watch(glazeNotifierProvider).stats.hasGlazed,
                onGlazeTap: () async {
                  await ref.read(glazeNotifierProvider.notifier).onGlazed(videoId: video.id).then(
                        (_) => ref.read(glazeNotifierProvider.notifier).getVideoGlazeStats(video.id),
                      );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
