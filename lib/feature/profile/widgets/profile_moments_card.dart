import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/moments/views/moments_videos_tabview.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/assets.gen.dart';
import '../../home/models/video_content/video_content.dart';

class ProfileMomentsCard extends StatelessWidget {
  const ProfileMomentsCard({
    super.key,
    this.videos,
    this.isLoading = false,
    required this.isCurrentUser,
  });

  final List<VideoContent>? videos;
  final bool isLoading;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
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
          else if (isCurrentUser)
            ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: videos?.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            height: 150,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: CachedNetworkImage(
                                imageUrl: videos?[index].thumbnailUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                videos?[index].title ?? 'Video Title',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.atSign,
                                    size: 12,
                                  ),
                                  Text(' ${videos?[index].category ?? ''}'),
                                  const Gap(10),
                                  SvgPicture.asset(
                                    Assets.images.svg.glazeDonutsIcon.path,
                                    height: 12,
                                  ),
                                  Text(' ${videos?[index].glazesCount ?? 0}'),
                                ],
                              ),
                              const Gap(4.0),
                              Text(
                                videos?[index].caption ?? 'Video Caption',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () async {
                                showCupertinoModalPopup<void>(
                                  context: context,
                                  builder: (BuildContext context) => CupertinoActionSheet(
                                    title: const Text('Options'),
                                    actions: <CupertinoActionSheetAction>[
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        isDestructiveAction: true,
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      isDefaultAction: true,
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          else
            MomentsVideosTabview(
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
