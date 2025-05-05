import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:go_router/go_router.dart';
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
    final router = GoRouter.of(context);

    return Container(
      width: width,
      height: 130,
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
                  router.push(const ChallengesRoute().location);
                },
                width: width / 2,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(Assets.images.svg.trophyIcon.path),
                    const Gap(10),
                    Text(video.category ?? ''),
                  ],
                ),
              ),
              const Gap(10),
              Text(
                video.title ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              GestureDetector(
                onTap: () async {
                  final userId = video.userId;
                  await controller?.pause();
                  router.push(
                    ViewUserProfileRoute(id: userId ?? '').location,
                    extra: {
                      'controller': controller,
                    },
                  );
                },
                child: Text(
                  'by @${video.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              Text(
                '# Trending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                child: SvgPicture.asset(Assets.images.svg.glazeDonutsIcon.path),
              ),
              const Gap(2),
              Text(
                '$glazeCount',
                style: Theme.of(context).textTheme.labelSmall,
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
