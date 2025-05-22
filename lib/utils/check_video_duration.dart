import 'dart:io';

import 'package:video_player/video_player.dart';

Future<Duration> getVideoDuration(File file) async {
  final controller = VideoPlayerController.file(file);

  try {
    await controller.initialize();
    return controller.value.duration;
  } finally {
    await controller.dispose();
  }
}
