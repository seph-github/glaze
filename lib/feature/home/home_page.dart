import 'package:flutter/material.dart';
import 'package:glaze/feature/home/view/video_player_view.dart';
import 'package:carousel_slider/carousel_slider.dart';

const List<String> urls = [
  'https://videos.pexels.com/video-files/17169505/17169505-hd_1080_1920_30fps.mp4',
  'https://videos.pexels.com/video-files/17687289/17687289-uhd_1440_2560_30fps.mp4',
  'https://videos.pexels.com/video-files/27868392/12251113_1080_1922_30fps.mp4',
  'https://videos.pexels.com/video-files/15000517/15000517-uhd_1296_2304_30fps.mp4'
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider.builder(
            itemCount: urls.length,
            itemBuilder: (context, index, realIndex) {
              return VideoPlayerView(
                url: urls[index],
              );
            },
            options: CarouselOptions(
              scrollDirection: Axis.vertical,
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              pageSnapping: true,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 4,
            left: 0,
            right: 0,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(Icons.account_circle),
                    Icon(Icons.account_circle),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.account_circle),
                    Icon(Icons.account_circle),
                    Icon(Icons.account_circle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
