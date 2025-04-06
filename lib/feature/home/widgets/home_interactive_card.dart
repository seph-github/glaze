import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../components/morphism_widget.dart';
import '../../../core/routing/router.dart';
import '../../../data/models/cached_video/cached_video.dart';

class HomeInteractiveCard extends StatelessWidget {
  const HomeInteractiveCard({
    super.key,
    required this.width,
    required this.height,
    required this.cachedVideos,
    required this.index,
    this.onGlazeTap,
    this.onGlazeLongPress,
    this.onShareTap,
    this.onShareLongPress,
  });

  final int index;
  final double width;
  final double height;

  final CachedVideo? cachedVideos;
  final VoidCallback? onGlazeTap;
  final VoidCallback? onGlazeLongPress;
  final VoidCallback? onShareTap;
  final VoidCallback? onShareLongPress;

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
                    const Text('Best Content'),
                  ],
                ),
              ),
              const Gap(10),
              Text(
                cachedVideos?.model?[index].title ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  final userId = cachedVideos?.model?[index].userId;

                  router.push(ViewUserProfileRoute(id: userId ?? '').location);
                },
                child: Text(
                  'By @${cachedVideos?.model?[index].username}',
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
                onTap: onGlazeTap,
                onLongPress: onGlazeLongPress,
                size: 45.0,
                child: SvgPicture.asset('assets/images/svg/Glaze Donuts Icon.svg'),
              ),
              const Gap(10),
              MorphismWidget.circle(
                onTap: onShareTap,
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
