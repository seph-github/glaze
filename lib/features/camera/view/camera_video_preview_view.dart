import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class CameraVideoPreviewView extends StatefulWidget {
  const CameraVideoPreviewView({super.key, required this.filePath});

  final String filePath;

  @override
  State<CameraVideoPreviewView> createState() => _CameraVideoPreviewViewState();
}

class _CameraVideoPreviewViewState extends State<CameraVideoPreviewView> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _initializeVideoFuture = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    _controller.setLooping(false);
    await _controller.play();
    log('Video size: ${_controller.value.size}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(onBackButtonPressed: () => context.pop()),
      child: FutureBuilder(
          future: _initializeVideoFuture,
          builder: (context, snapshot) {
            log('preview aspect ratio: ${_controller.value}');
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenRatio = constraints.maxHeight / constraints.maxWidth;
                        final previewRatio = _controller.value.size.width / _controller.value.size.height;

                        return OverflowBox(
                          maxHeight: screenRatio > previewRatio ? constraints.maxHeight : constraints.maxWidth / previewRatio,
                          maxWidth: screenRatio > previewRatio ? constraints.maxHeight * previewRatio : constraints.maxWidth,
                          child: VideoPlayer(_controller),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 100.0,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            await _controller.dispose();

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          child: const Text('Take Again'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _controller.pause();

                            if (context.mounted) {
                              await const CameraContentFormRoute().push<void>(context);
                            }
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Video error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
