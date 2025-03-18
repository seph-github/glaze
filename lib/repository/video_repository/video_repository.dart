import 'dart:developer';
import 'dart:io';

import 'package:glaze/data/entities/video_entity.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_compress/video_compress.dart';

import '../../core/services/supabase_services.dart';
import '../auth_service/auth_service_provider.dart';

part 'video_repository.g.dart';

@riverpod
VideoRepository videoRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return VideoRepository(supabaseService: supabaseService);
}

@riverpod
class VideoNotifier extends _$VideoNotifier {
  @override
  Future<List<VideoModel>> build() async {
    return ref.watch(videoRepositoryProvider).fetchVideos();
  }
}

@riverpod
class VideoUploadNotifier extends _$VideoUploadNotifier {
  @override
  Future<void> build() async {}

  Future<void> uploadVideo({required File file, required String title}) async {
    try {
      final user = await ref.watch(authServiceProvider).getCurrentUser();

      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          await ref
              .watch(videoRepositoryProvider)
              .uploadVideo(file: file, userId: user?.id ?? '', title: title);
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

class VideoRepository {
  const VideoRepository({required this.supabaseService});

  final SupabaseService supabaseService;
  Future<List<VideoModel>> fetchVideos() async {
    try {
      final videos = await supabaseService.select(table: 'videos');

      final value = videos
          .map<VideoModel>(
            (video) => VideoModel.fromJson(video),
          )
          .toList();

      value.sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );

      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadVideo(
      {required File file,
      required String userId,
      required String title}) async {
    try {
      final url = await supabaseService.upload(
          file: file, userId: userId, bucketName: 'videos');

      final thumbnailFile = await _getVideoThumbnail(file);

      final thumbnailUrl = await supabaseService.upload(
          file: thumbnailFile, userId: userId, bucketName: 'thumbnails');

      log('thumbnailUrl: $thumbnailUrl');
      log('video_url: $url');

      final data = VideoEntity(
        caption: title,
        thumbnailUrl: thumbnailUrl,
        videoUrl: url,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await supabaseService.insert(
        table: 'videos',
        data: data.toMap(),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

// _compressVideo(File file) async {
//   // TODO: implement _compressVideo
//   final MediaInfo? info = await VideoCompress.compressVideo(
//     file.path,
//     quality: VideoQuality.HighestQuality,
//     deleteOrigin: false,
//   );
// }

Future<File> _getVideoThumbnail(File file) async {
  final thumbnailFile = await VideoCompress.getFileThumbnail(file.path,
      quality: 100, position: -1);
  return thumbnailFile;
}
