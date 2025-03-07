import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.url});

  final String url;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _videoPlayerController;
  bool _isError = false;
  bool _showControls = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _preloadVideo(widget.url);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  Future<File> _ensureMp4Extension(File file) async {
    if (!file.path.toLowerCase().endsWith('.mp4')) {
      final newPath = "${file.path}.mp4";
      final newFile = await file.copy(newPath);
      return newFile;
    }
    return file;
  }

  Future<File> _moveToTemporaryDirectory(File file) async {
    final tempDir = await getTemporaryDirectory();
    final newPath = "${tempDir.path}/${file.uri.pathSegments.last}";

    return file.copy(newPath);
  }

  Future<void> _preloadVideo(String url) async {
    try {
      final config = Config(
        'customCacheKey',
        stalePeriod: const Duration(hours: 6),
        maxNrOfCacheObjects: 20,
      );

      final cacheManager = CacheManager(config);

      File file = await cacheManager.getSingleFile(url);
      file = await _ensureMp4Extension(file);
      file = await _moveToTemporaryDirectory(file);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true); // Set the video to loop

      if (mounted) {
        setState(() {
          _videoPlayerController = controller;
        });

        controller.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 1), () {
        setState(() {
          _showControls = false;
        });
      });
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isError
            ? const Text('Error loading video')
            : _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      _toggleControls();
                      _togglePlayPause();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                        if (_showControls)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _videoPlayerController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
