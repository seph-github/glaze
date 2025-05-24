import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/assets.gen.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer({
    super.key,
    required this.controller,
    required this.videoId,
    required this.currentActiveVideoId,
  });

  final VideoPlayerController? controller;
  final String videoId;
  final String currentActiveVideoId;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  bool _isBuffering = false;
  VideoPlayerController? _oldController;
  String? _currentVideoId;
  bool _isPlaying = false;
  final Key _playerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _oldController = widget.controller;
    _currentVideoId = widget.videoId;
    _addControllerListener();
  }

  void _addControllerListener() {
    if (widget.controller != null) {
      _isBuffering = widget.controller!.value.isBuffering;
      _isPlaying = widget.controller!.value.isPlaying;
      widget.controller!.addListener(_onControllerUpdate);
    }
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    super.didUpdateWidget(oldWidget);

    final bool isNowActive = widget.videoId == widget.currentActiveVideoId;

    if (!isNowActive && widget.controller?.value.isPlaying == true) {
      widget.controller?.pause();
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _oldController?.removeListener(_onControllerUpdate);
    _oldController = null;
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted || widget.controller == null) return;

    final controller = widget.controller;

    if (controller == null) return;

    if (widget.videoId != _currentVideoId) return;

    // Check if controller is disposed or in error state
    if (controller.value.hasError) {
      // Schedule UI update for next frame to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isBuffering = false);
      });
      return;
    }

    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;

    // Hide buffering indicator if:
    // 1. Video is actually playing and has advanced
    // 2. Video has loaded content (position > 0)
    // 3. Video duration is known and valid
    bool shouldShowBuffering = isBuffering;
    if ((isPlaying && controller.value.position > Duration.zero) || (controller.value.position > Duration.zero && controller.value.duration.inMilliseconds > 0)) {
      shouldShowBuffering = false;
    }

    // Only update state if something changed
    if (_isBuffering != shouldShowBuffering || _isPlaying != isPlaying) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBuffering = shouldShowBuffering;
            _isPlaying = isPlaying;
          });
        }
      });
    }
  }

  Timer? timer;
  bool showIcon = false;

  void _startHideTimer() {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 1500),
      () {
        showIcon = false;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showIcon = true;
        _startHideTimer();

        // Schedule state updates for the next frame to avoid build errors
        if (controller.value.isPlaying) {
          controller.pause().then((_) {
            if (mounted) {
              // Use post-frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            }
          }).catchError((e) {
            debugPrint('Error pausing video: $e');
          });
        } else {
          controller.play().then((_) {
            if (mounted) {
              // Use post-frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            }
          }).catchError((e) {
            debugPrint('Error playing video: $e');
          });
        }
      },
      child: Stack(
        key: _playerKey,
        children: [
          if (controller.value.size.height > 640)
            VideoPlayer(controller)
          else
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          if (showIcon)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: SvgPicture.asset(Assets.images.svg.playIcon.path, height: 24.0),
              ),
            ),
          if (_isBuffering) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
