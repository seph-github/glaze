import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/home/provider/video_content_provider.dart';
import 'package:shimmer/shimmer.dart';

class MomentsVideosTabview extends StatelessWidget {
  const MomentsVideosTabview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(videoContentNotifierProvider);

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 9 / 16,
          ),
          padding: const EdgeInsets.only(top: 8.0),
          itemCount: state.cachedVideoContent?.videoContents?.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: state
                      .cachedVideoContent?.videoContents?[index].thumbnailUrl ??
                  '',
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
              // const Center(
              //   child: CircularProgressIndicator(
              //     color: ColorPallete.primaryColor,
              //   ),
              // ),
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
            );
          },
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
