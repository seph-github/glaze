import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class MomentsVideosTabview extends StatelessWidget {
  const MomentsVideosTabview({
    super.key,
    this.videos,
    bool? primary,
    bool? shrinkWrap,
    ScrollPhysics? physics,
  })  : _physics = physics ?? const AlwaysScrollableScrollPhysics(),
        _primary = primary ?? true,
        _shinkWrap = shrinkWrap ?? false;

  final List<VideoContent>? videos;
  final bool _primary;
  final bool _shinkWrap;
  final ScrollPhysics? _physics;

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    if (videos!.isEmpty) {
      return const Center(
        child: Text('No Videos Found!'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
      ),
      padding: const EdgeInsets.only(top: 8.0),
      primary: _primary,
      shrinkWrap: _shinkWrap,
      physics: _physics,
      itemCount: videos?.length ?? 0,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            router.push(
              const VideoPreviewRoute().location,
              extra: {
                'videos': videos,
                'initialIndex': index,
              },
            );
          },
          child: CachedNetworkImage(
            imageUrl: videos?[index].thumbnailUrl ?? '',
            placeholder: (context, url) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.all(1.0),
                  color: Colors.grey,
                ),
              );
            },
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class MomentsVideoFetchShimmer extends StatelessWidget {
  const MomentsVideoFetchShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.all(1.0),
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
