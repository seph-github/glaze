import 'dart:developer';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:glaze/data/entities/video_entity.dart';
import 'package:glaze/data/models/cached_video/cached_video.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../core/services/supabase_services.dart';
import '../auth_repository/auth_repository_provider.dart';

part 'video_repository.g.dart';

@riverpod
VideoRepository videoRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return VideoRepository(supabaseService: supabaseService);
}

@riverpod
class VideosNotifier extends _$VideosNotifier {
  @override
  Future<List<VideoModel>> build() async {
    return ref.watch(videoRepositoryProvider).fetchVideos();
  }
}

@riverpod
class CacheVideoNotifier extends _$CacheVideoNotifier {
  @override
  Future<CachedVideo> build() async {
    final data = await ref.watch(videoRepositoryProvider).fetchVideos();

    List<Config> config = List.generate(
      data.length,
      (index) => Config(
        data[index].videoUrl,
        stalePeriod: const Duration(hours: 6),
        maxNrOfCacheObjects: 20,
      ),
    )
        .map(
          (e) => e,
        )
        .toList();

    final List<CacheManager> cacheManager =
        config.map((cache) => CacheManager(cache)).toList();

    final List<VideoPlayerController> controllers = List.generate(
        cacheManager.length, (index) => VideoPlayerController.file(File('')),
        growable: true);
    for (int index = 0; index < cacheManager.length; index++) {
      final List<File> files = List.generate(
        cacheManager.length,
        (index) => File(''),
      );
      files[index] =
          await cacheManager[index].getSingleFile(data[index].videoUrl);

      files[index] = await _ensureMp4Extension(files[index]);
      files[index] = await _moveToTemporaryDirectory(files[index]);

      controllers[index] = VideoPlayerController.file(files[index]);

      await controllers[index].initialize();
      controllers[index].setLooping(true);
      controllers[index].value.aspectRatio;
      controllers[index].play();
    }
    // return {'videos': data, 'controllers': controllers};
    return CachedVideo(model: data, controllers: controllers);
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
}

@riverpod
class VideoUploadNotifier extends _$VideoUploadNotifier {
  @override
  Future<void> build() async {}

  Future<void> uploadVideo({
    required File file,
    required String title,
    required String caption,
    required String category,
    required String publishAs,
  }) async {
    try {
      final user = await ref.watch(authServiceProvider).getCurrentUser();

      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          await ref.watch(videoRepositoryProvider).uploadVideo(
                file: file,
                userId: user?.id ?? '',
                caption: caption,
                category: category,
                title: title,
                publishAs: publishAs,
              );
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
      // final videos = await supabaseService.select(table: 'videos');
      final videos = await supabaseService.withReturnValuesRpc(
          fn: 'select_videos_with_owners');

      final value = videos
          .map<VideoModel>(
            (video) => VideoModel.fromJson(video),
          )
          .toList();

      value.sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      // log('videos $value');
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadVideo({
    required File file,
    required String userId,
    required String title,
    required String caption,
    required String category,
    required String publishAs,
  }) async {
    try {
      final url = await supabaseService.upload(
          file: file, userId: userId, bucketName: 'videos');

      final thumbnailFile = await _getVideoThumbnail(file);

      final thumbnailUrl = await supabaseService.upload(
          file: thumbnailFile, userId: userId, bucketName: 'thumbnails');

      log('thumbnailUrl: $thumbnailUrl');
      log('video_url: $url');

      final data = VideoEntity(
        title: title,
        caption: caption,
        category: category,
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
