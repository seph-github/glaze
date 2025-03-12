import 'package:glaze/models/video/video_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/supabase_services.dart';

part 'video_provider.g.dart';

@riverpod
VideoService videoService(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return VideoService(supabaseService: supabaseService);
}

@riverpod
class VideoNotifier extends _$VideoNotifier {
  @override
  Future<List<VideoModel>> build() async {
    return ref.watch(videoServiceProvider).fetchVideos();
  }
}

class VideoService {
  const VideoService({required this.supabaseService});

  final SupabaseService supabaseService;
  Future<List<VideoModel>> fetchVideos() async {
    try {
      final videos = await supabaseService.select(table: 'videos');

      final returnValue = videos
          .map<VideoModel>((video) => VideoModel.fromJson(video))
          .toList();
      return returnValue;
    } catch (e) {
      rethrow;
    }
  }
}
