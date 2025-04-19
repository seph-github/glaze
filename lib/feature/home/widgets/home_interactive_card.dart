import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/home/models/video_content.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../components/morphism_widget.dart';
import '../../../core/routing/router.dart';
import '../models/cached_video_content.dart';

class HomeInteractiveCard extends StatelessWidget {
  const HomeInteractiveCard({
    super.key,
    required this.width,
    required this.height,
    this.cachedVideos,
    this.video,
    required this.index,
    this.onGlazeTap,
    this.onGlazeLongPress,
    this.onShareTap,
    this.onShareLongPress,
    this.isGlazed = false,
    this.controller,
  });

  final int index;
  final double width;
  final double height;
  final bool isGlazed;

  final CachedVideoContent? cachedVideos;
  final VideoContent? video;
  final VoidCallback? onGlazeTap;
  final VoidCallback? onGlazeLongPress;
  final VoidCallback? onShareTap;
  final VoidCallback? onShareLongPress;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Container(
      width: width,
      height: 150,
      padding: const EdgeInsets.all(16.0),
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
                    SvgPicture.asset('assets/images/svg/Trophy Icon.svg'),
                    const Gap(10),
                    Text(video?.category ?? ''),
                  ],
                ),
              ),
              const Gap(10),
              Text(
                video?.title ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  final userId = video?.userId;
                  await controller?.pause();
                  router.push(
                    ViewUserProfileRoute(id: userId ?? '').location,
                    extra: {
                      'controller': controller,
                    },
                  );
                },
                child: Text(
                  'by @${video?.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '# Trending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                child: SvgPicture.asset('assets/images/svg/Glaze Donuts Icon.svg'),
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
