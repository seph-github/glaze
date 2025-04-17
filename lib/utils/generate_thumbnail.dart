import 'dart:io';

import 'package:video_compress/video_compress.dart';

Future<File> getVideoThumbnail(File file) async {
  final thumbnailFile = await VideoCompress.getFileThumbnail(
    file.path,
    quality: 100,
    position: -1,
  );
  return thumbnailFile;
}
