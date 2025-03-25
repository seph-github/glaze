import 'package:flutter/material.dart';
import 'package:glaze/data/models/video/videos.dart';

class ProfileMomentsCard extends StatelessWidget {
  const ProfileMomentsCard({
    super.key,
    this.videos,
    this.isLoading = false,
  });

  final List<Videos>? videos;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Moments',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 12),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : videos == null || videos?.isEmpty == true
                  ? const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text('No videos'),
                      ),
                    )
                  : SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: videos?.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 14 / 16,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              clipBehavior: Clip.antiAlias,
                              height: 200,
                              width: MediaQuery.sizeOf(context).width / 2.5,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                              ),
                              child: Image.network(
                                videos![index].thumbnailUrl ?? '',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          );
                        },
                      ),
                    )
        ],
      ),
    );
  }
}
