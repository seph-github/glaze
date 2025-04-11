import 'dart:io';

import 'package:glaze/feature/home/entity/video_content_entity.dart';
import 'package:glaze/feature/home/models/video_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';

class VideoContentServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<VideoContent>> fetchVideoContents() async {
    try {
      final response = await _supabaseClient.rpc('select_videos_with_owners');

      print('Fetched video contents service: $response');

      final rawList = response as List<dynamic>; // explicitly cast

      final value = rawList.map((video) => VideoContent.fromJson(video as Map<String, dynamic>)).toList();

      value.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      return value;
    } catch (e) {
      print('Error fetching video contents: $e');
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
      final String dirName = '$userId/${file.path.split('/').last}';
      final thumbnailFile = await _getVideoThumbnail(file);

      final thumbnailDirName = '$userId/${thumbnailFile.path.split('/').last}';

      final urlResult = await _supabaseClient.storage.from('videos').upload(dirName, file);

      final thumbnailResult = await _supabaseClient.storage.from('thumbnails').upload(thumbnailDirName, thumbnailFile);

      final url = _supabaseClient.storage.from('videos').getPublicUrl(urlResult);
      final filteredUrl = removeDuplicateWords(url);
      final thumbnailUrl = _supabaseClient.storage.from('thumbnails').getPublicUrl(thumbnailResult);
      final filteredThumbnailUrl = removeDuplicateWords(thumbnailUrl);

      final entity = VideoContentEntity(
        userId: userId,
        title: title,
        caption: caption,
        category: category,
        videoUrl: filteredUrl,
        thumbnailUrl: filteredThumbnailUrl,
      );

      await _supabaseClient.from('videos').insert(
            entity.toMap(),
          );

      return 'Video Uploaded Successfully';
    } catch (e) {
      print('Error uploading video content: $e');
      rethrow;
    }
  }

  String removeDuplicateWords(String url) {
    final parts = url.split('/');
    final uniqueParts = parts.toSet().toList();
    return uniqueParts.join('/');
  }

  Future<File> _getVideoThumbnail(File file) async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(file.path, quality: 100, position: -1);
    return thumbnailFile;
  }
}
