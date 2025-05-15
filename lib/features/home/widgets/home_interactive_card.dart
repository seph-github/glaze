import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../components/morphism_widget.dart';
import '../../../core/navigation/router.dart';
import '../../../gen/assets.gen.dart';
import '../models/cached_video_content/cached_video_content.dart';

class HomeInteractiveCard extends HookConsumerWidget {
  const HomeInteractiveCard({
    super.key,
    required this.width,
    required this.height,
    this.cachedVideos,
    required this.video,
    this.onGlazeTap,
    this.onGlazeLongPress,
    this.onShareTap,
    this.onShareLongPress,
    this.isGlazed = false,
    this.controller,
    this.glazeCount = 0,
  });

  final double width;
  final double height;
  final bool isGlazed;

  final CachedVideoContent? cachedVideos;
  final VideoContent video;
  final VoidCallback? onGlazeTap;
  final VoidCallback? onGlazeLongPress;
  final VoidCallback? onShareTap;
  final VoidCallback? onShareLongPress;
  final VideoPlayerController? controller;
  final int glazeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: width,
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 0),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MorphismWidget.rounded(
                onTap: () {
                  // TODO: Challenges screen
                  // router.push(const ChallengesRoute().location);
                },
                width: width / 2.25,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(Assets.images.svg.trophyIcon.path),
                    const Gap(10),
                    Text(
                      video.category ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              GestureDetector(
                onTap: () async {
                  final userId = video.userId as String;
                  await controller?.pause();

                  if (context.mounted) {
                    await ViewUserProfileRoute(id: userId, $extra: {
                      'controller': controller,
                    }).push<void>(context);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.profileImageUrl ?? '',
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 15.0,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                          SvgPicture.asset(Assets.images.svg.profileIcon.path),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.account_circle_outlined),
                    ),
                    const Gap(8),
                    Text(
                      '@${video.username}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                video.title ?? '',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              Text(
                video.caption ?? '',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              MorphismWidget.circle(
                color: isGlazed ? ColorPallete.primaryColor : null,
                onTap: onGlazeTap,
                onLongPress: onGlazeLongPress,
                size: 45.0,
                child: Image.asset(
                  Assets.images.png.chocolatesprinkles.path,
                  scale: 0.75,
                  height: 36,
                ),
              ),
              const Gap(2),
              Text(
                '$glazeCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const Gap(10),
              MorphismWidget.circle(
                onTap: () {
                  onShareTap?.call();
                },
                onLongPress: onShareLongPress,
                size: 45.0,
                child: SvgPicture.asset('assets/images/svg/share_icon.svg'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
