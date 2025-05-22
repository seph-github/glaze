import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/features/moments/providers/upload_moments_form_provider/upload_moments_form_provider.dart';
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
    _controller.setLooping(true);
    await _controller.play();
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    height: 100.0,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                          onPressed: () async {
                            await _controller.dispose();

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          child: const Text('Take Again'),
                        ),
                        Consumer(builder: (context, ref, _) {
                          return TextButton(
                            onPressed: () async {
                              await _controller.pause();

                              ref.read(uploadMomentFormProvider.notifier).setFile(
                                    File(widget.filePath),
                                  );
                              ref.read(uploadMomentFormProvider.notifier).syncControllersToState();

                              if (context.mounted) {
                                await const CameraContentFormRoute().push<void>(context);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            child: const Text('Next'),
                          );
                        }),
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
