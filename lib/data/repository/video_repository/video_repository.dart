import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:glaze/core/result_handler/results.dart';
import 'package:glaze/data/entities/video_entity.dart';
import 'package:glaze/data/models/cached_video/cached_video.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../core/services/supabase_services.dart';
import '../../../feature/auth/services/auth_services.dart';

part 'video_repository.g.dart';

@riverpod
VideoRepository videoRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return VideoRepository(supabaseService: supabaseService);
}

@riverpod
class VideosNotifier extends _$VideosNotifier {
  @override
  FutureOr<Result<List<VideoModel>, Exception>> build() async {
    try {
      final response = await ref.watch(videoRepositoryProvider).fetchVideos();

      if (response is Success<List<VideoModel>, Exception>) {
        return Success<List<VideoModel>, Exception>(response.value);
      }
      return Failure<List<VideoModel>, Exception>(response as Exception);
    } on Exception catch (e) {
      return Failure<List<VideoModel>, Exception>(e);
    }
  }
}

@riverpod
class CacheVideoNotifier extends _$CacheVideoNotifier {
  @override
  Future<Result<CachedVideo, Exception>> build() async {
    Result<List<VideoModel>, Exception> data = await ref.watch(videoRepositoryProvider).fetchVideos();

    if (data is Success<List<VideoModel>, Exception>) {
      final List<VideoModel> value = data.value;

      List<Config> config = List.generate(
        value.length,
        (index) => Config(
          value[index].videoUrl,
          stalePeriod: const Duration(hours: 6),
          maxNrOfCacheObjects: 20,
        ),
      )
          .map(
            (e) => e,
          )
          .toList();

      final List<CacheManager> cacheManager = config.map((cache) => CacheManager(cache)).toList();

      final List<VideoPlayerController> controllers = List.generate(cacheManager.length, (index) => VideoPlayerController.file(File('')), growable: true);
      for (int index = 0; index < cacheManager.length; index++) {
        final List<File> files = List.generate(
          cacheManager.length,
          (index) => File(''),
        );
        files[index] = await cacheManager[index].getSingleFile(value[index].videoUrl);

        files[index] = await _ensureMp4Extension(files[index]);
        files[index] = await _moveToTemporaryDirectory(files[index]);

        controllers[index] = VideoPlayerController.file(files[index]);

        await controllers[index].initialize();
        controllers[index].setLooping(true);

        if (index == 0) {
          controllers[index].play();
        } else {
          controllers[index].pause();
        }
      }

      return Success<CachedVideo, Exception>(
        CachedVideo(model: value, controllers: controllers),
      );
    }

    return Failure<CachedVideo, Exception>(
      Exception(data as Exception),
    );
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
  FutureOr<Result<String, Exception>> build() async => const Success<String, Exception>('');

  Future<Result<String, Exception>> uploadVideo({
    required File file,
    required String title,
    required String caption,
    required String category,
  }) async {
    try {
      final user = AuthServices().currentUser;

      state = const AsyncLoading();
      final result = await AsyncValue.guard(
        () async => await ref.watch(videoRepositoryProvider).uploadVideo(
              file: file,
              userId: user?.id ?? '',
              caption: caption,
              category: category,
              title: title,
            ),
      );

      state = result;

      if (result.value is Success<String, Exception>) {
        return result.value!;
      } else if (result.value is Failure<String, Exception>) {
        final failure = result.value as Failure<String, Exception>;
        return Failure<String, Exception>(failure.error);
      }

      return const Success<String, Exception>('');
    } on Exception catch (e) {
      return Failure<String, Exception>(e);
    }
  }
}

class VideoRepository {
  const VideoRepository({required this.supabaseService});

  final SupabaseService supabaseService;
  Future<Result<List<VideoModel>, Exception>> fetchVideos() async {
    try {
      final videos = await supabaseService.withReturnValuesRpc(fn: 'select_videos_with_owners');

      final value = videos
          .map<VideoModel>(
            (video) => VideoModel.fromJson(video),
          )
          .toList();

      value.sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return Success<List<VideoModel>, Exception>(value);
    } on Exception catch (e) {
      return Failure<List<VideoModel>, Exception>(e);
    }
  }

  Future<Result<String, Exception>> uploadVideo({
    required File file,
    required String userId,
    required String title,
    required String caption,
    required String category,
  }) async {
    try {
      final urlResult = await supabaseService.upload(file: file, userId: userId, bucketName: 'videos');

      if (urlResult is Failure<String, Exception>) {
        final exception = urlResult.error; // Extract the actual exception
        return Failure<String, Exception>(exception);
      }

      if (urlResult is Success<String, Exception>) {
        final thumbnailFile = await _getVideoThumbnail(
          file,
        );

        final thumbnailUrl = await supabaseService.upload(file: thumbnailFile, userId: userId, bucketName: 'thumbnails');

        if (thumbnailUrl is Failure<String, Exception>) {
          return Failure<String, Exception>(thumbnailUrl as Exception);
        } else if (thumbnailUrl is Success<String, Exception>) {
          final data = VideoEntity(
            title: title,
            caption: caption,
            category: category,
            thumbnailUrl: thumbnailUrl.value,
            videoUrl: urlResult.value,
            glazesCount: 0,
            userId: userId,
            status: 'active',
            createdAt: DateTime.now(),
          );

          await supabaseService.insert(
            table: 'videos',
            data: data.toMap(),
          );
        }

        return const Success<String, Exception>('Successfully uploaded');
      }

      return Failure<String, StorageException>(urlResult as StorageException);
    } on StorageException catch (e) {
      return Failure<String, StorageException>(e);
    }
  }
}

// Future<File> _compressVideo(File file) async {
//   // TODO: implement _compressVideo
//   final MediaInfo? info = await VideoCompress.compressVideo(
//     file.path,
//     quality: VideoQuality.LowQuality,
//     deleteOrigin: false,
//   );

//   return File(info!.path!);
// }

Future<File> _getVideoThumbnail(File file) async {
  final thumbnailFile = await VideoCompress.getFileThumbnail(file.path, quality: 100, position: -1);
  return thumbnailFile;
}
