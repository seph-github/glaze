import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../profile/provider/profile_provider/profile_provider.dart';

class MomentsVideosTabview extends StatelessWidget {
  const MomentsVideosTabview({
    super.key,
    this.videos,
    this.isCurrentUser = false,
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
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
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
      addAutomaticKeepAlives: true,
      physics: _physics,
      itemCount: videos?.length ?? 0,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            await VideoPreviewRoute(videos as List<VideoContent>, initialIndex: index).push<void>(context);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCacheImage(videos![index]),
              if (isCurrentUser)
                Align(
                  alignment: Alignment.topRight,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return IconButton(
                        onPressed: () async {
                          _showVideoActions(context, ref, index);
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(vertical: -2, horizontal: -2),
                        ),
                        icon: const Icon(
                          Icons.more_horiz,
                          color: ColorPallete.white,
                          size: 24.0,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCacheImage(VideoContent video) {
    return CachedNetworkImage(
      key: PageStorageKey('Thumbnail_${video.id}'),
      cacheKey: 'thumbnail_${video.id}',
      imageUrl: video.thumbnailUrl ?? '',
      memCacheHeight: 1280,
      memCacheWidth: 720,
      maxHeightDiskCache: 1280,
      maxWidthDiskCache: 720,
      filterQuality: FilterQuality.high,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
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
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }

  Future<void> _showVideoActions(BuildContext context, WidgetRef ref, int index) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Edit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              await Dialogs.dualActionContentDialog(
                context,
                title: 'Confirm Video Deletion',
                content: 'This action is permanent and cannot be undone. Deleting the video will remove it from your profile and erase all associated data. Are you sure you want to proceed?',
                onCancel: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
                onConfirm: () async {
                  if (context.canPop()) {
                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  }
                  await ref.read(profileNotifierProvider.notifier).deleteVideoById(videos![index].id);
                },
              );
            },
            isDestructiveAction: true,
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.blue,
                ),
          ),
        ),
      ),
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
