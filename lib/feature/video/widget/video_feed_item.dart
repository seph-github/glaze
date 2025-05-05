import 'package:flutter/material.dart';
import 'package:glaze/feature/home/models/video_content/video_content.dart';
import 'package:video_player/video_player.dart';

import 'optimized_video_player.dart';
import 'video_overlay_section.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({super.key, required this.videoItem, required this.controller});

  final VideoContent videoItem;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OptimizedVideoPlayer(controller: controller, videoId: videoItem.id),
        VideoOverlaySection(
          profileImageUrl: videoItem.thumbnailUrl ?? '',
          username: videoItem.username ?? '',
          description: videoItem.caption ?? '',
          isBookmarked: false,
          isLiked: false,
          likeCount: videoItem.glazesCount ?? 0,
          commentCount: 0,
          shareCount: 0,
        ),
      ],
    );
  }
}
