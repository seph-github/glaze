import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/result_handler/results.dart';
import '../../../data/repository/video_repository/video_repository.dart';

class MomentsVideosTabview extends StatelessWidget {
  const MomentsVideosTabview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(videosNotifierProvider);

        return state.when(
          data: (data) {
            if (data is Success<List<VideoModel>, Exception>) {
              final List<VideoModel> result = data.value;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 9 / 16,
                ),
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: result.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: result[index].thumbnailUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  );
                },
              );
            }

            if (data is Success<List<VideoModel>, Exception>) {
              return const Center(
                child: Text('No data available'),
              );
            }

            return const Center(
              child: Text('No data available'),
            );
          },
          error: (error, stackTrace) => const Center(
            child: Text('No data available'),
          ),
          loading: () => const MomentsVideoFetchShimmer(),
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
