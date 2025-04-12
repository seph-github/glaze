import 'dart:io';

import 'package:glaze/feature/home/entity/video_content_entity.dart';
import 'package:glaze/feature/home/models/video_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';

import '../../../core/services/storage_services.dart';

class VideoContentServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<VideoContent>> fetchVideoContents() async {
    try {
      final response = await _supabaseClient.rpc('select_videos_with_owners');

      final rawList = response as List<dynamic>; // explicitly cast

      final value = rawList
          .map((video) => VideoContent.fromJson(video as Map<String, dynamic>))
          .toList();

      value.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadVideoContent({
    required File file,
    required String userId,
    required String title,
    required String caption,
    required String category,
  }) async {
    try {
      final videoUrl = await StorageServices().upload(
        id: userId,
        bucketName: 'videos',
        file: file,
      );

      final thumbnailFile = await _getVideoThumbnail(file);

      final thumbnailUrl = await StorageServices().upload(
        id: userId,
        bucketName: 'thumbnails',
        file: thumbnailFile,
      );

      final entity = VideoContentEntity(
        userId: userId,
        title: title,
        caption: caption,
        category: category,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      await _supabaseClient.from('videos').insert(
            entity.toMap(),
          );

      return 'Video Uploaded Successfully';
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _getVideoThumbnail(File file) async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(file.path,
        quality: 100, position: -1);
    return thumbnailFile;
  }
}
