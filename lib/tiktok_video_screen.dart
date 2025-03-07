import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TikTokVideoScreen extends StatefulWidget {
  @override
  _TikTokVideoScreenState createState() => _TikTokVideoScreenState();
}

class _TikTokVideoScreenState extends State<TikTokVideoScreen> {
  final List<String> videoUrls = [
    "https://www.example.com/video1.mp4",
    "https://www.example.com/video2.mp4",
    "https://www.example.com/video3.mp4",
  ];

  final Map<int, VideoPlayerController> controllers = {};
  final PageController pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _preloadVideo(0); // Preload the first video
  }

  /// Helper function to ensure the video file has a proper extension.
  Future<File> getVideoFileWithExtension(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    // If the file path does not end with '.mp4', copy it to a new file with '.mp4'
    if (!file.path.toLowerCase().endsWith('.mp4')) {
      final newPath = file.path + ".mp4";
      final newFile = await file.copy(newPath);
      return newFile;
    }
    return file;
  }

  Future<void> _preloadVideo(int index) async {
    if (index < 0 || index >= videoUrls.length) return;
    if (controllers.containsKey(index)) return; // Video already loaded

    try {
      final file = await getVideoFileWithExtension(videoUrls[index]);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      setState(() {
        controllers[index] = controller;
      });
      if (index == currentIndex) {
        controller.play(); // Play current video
      }
    } catch (e) {
      print("Error caching video: $e");
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    // Pause previous and next videos if available
    controllers[currentIndex - 1]?.pause();
    controllers[currentIndex + 1]?.pause();

    // Play the current video if initialized; otherwise, preload it
    if (controllers.containsKey(currentIndex)) {
      controllers[currentIndex]?.play();
    } else {
      _preloadVideo(currentIndex);
    }

    // Preload the next video
    _preloadVideo(currentIndex + 1);
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical, // TikTok-style vertical scrolling
        itemCount: videoUrls.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          if (!controllers.containsKey(index) ||
              !controllers[index]!.value.isInitialized) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(
            child: AspectRatio(
              aspectRatio: controllers[index]!.value.aspectRatio,
              child: VideoPlayer(controllers[index]!),
            ),
          );
        },
      ),
    );
  }
}
