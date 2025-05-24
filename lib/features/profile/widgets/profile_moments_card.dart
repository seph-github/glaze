import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:glaze/features/moments/views/moments_videos_tabview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../home/models/video_content/video_content.dart';

class ProfileMomentsCard extends ConsumerWidget {
  const ProfileMomentsCard({
    super.key,
    this.videos,
    required this.isCurrentUser,
  });

  final List<VideoContent>? videos;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Moments',
            style: TextStyle(fontSize: 20),
          ),
          if (videos == null || videos?.isEmpty == true)
            const SizedBox(
              height: 50,
              child: Center(
                child: Text('No videos'),
              ),
            )
          else
            MomentsVideosTabview(
              isCurrentUser: isCurrentUser,
              videos: videos,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
        ],
      ),
    );
  }
}
