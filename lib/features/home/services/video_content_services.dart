import 'package:glaze/features/auth/services/auth_services.dart';
import 'package:glaze/features/home/entity/video_content_entity.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:glaze/features/camera/provider/upload_moments_form_provider/upload_moments_form_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/storage_services.dart';

class VideoContentServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<VideoContent>> fetchAllVideos() async {
    try {
      final response = await _supabaseClient.rpc('select_videos_with_owners');

      final rawList = response as List<dynamic>;

      final value = rawList.map((video) => VideoContent.fromJson(video as Map<String, dynamic>)).toList();

      value.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VideoContent>> loadVideos(int offset) async {
    try {
      final user = AuthServices().currentUser;
      final response = await _supabaseClient.rpc(
        'select_videos_paginating',
        params: {
          'uid': user?.id,
          'page_limit': 2,
          'page_offset': offset,
        },
      );

      final rawList = response as List<dynamic>;

      final value = rawList.map((video) => VideoContent.fromJson(video as Map<String, dynamic>)).toList();

      value.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoContent> uploadVideoContent({
    required UploadMomentFormState form,
    required String userId,
  }) async {
    try {
      final videoUrl = await StorageServices().upload(
        id: userId,
        bucketName: 'videos',
        file: form.file!,
        fileName: form.title!,
      );

      final thumbnailUrl = await StorageServices().upload(
        id: userId,
        bucketName: 'thumbnails',
        file: form.thumbnail!,
        fileName: form.title!,
      );

      final entity = VideoContentEntity(
        userId: userId,
        title: form.title as String,
        caption: form.caption as String,
        category: form.category as String,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        location: form.location,
        latitude: form.latitude,
        longitude: form.longitude,
        tags: form.tags,
      );

      final response = await _supabaseClient
          .from('videos')
          .insert(
            entity.toMap(),
          )
          .select()
          .single();

      if (response.containsKey('id')) {
        response['video_id'] = response.remove('id');
      }

      return VideoContent.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> deleteVideoById(String id) async {
    try {
      final data = await _supabaseClient.from('videos').delete().eq('id', id);

      if (data != null) {
        throw Exception('Failed to delete video.');
      }

      return 'Video Deleted Successfully!';
    } catch (e) {
      rethrow;
    }
  }
}
