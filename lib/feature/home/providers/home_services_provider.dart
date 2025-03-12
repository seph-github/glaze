// import 'package:glaze/models/video/video_model.dart';
// import 'package:glaze/services/supabase_services.dart';

// class HomeService {
//   const HomeService({required this.supabaseService});

//   final SupabaseService supabaseService;

//   Future<List<VideoModel>> fetchVideos() async {
//     try {
//       final videos = await supabaseService.select(table: 'videos');

//       return videos
//           .map<VideoModel>((video) => VideoModel.fromJson(video))
//           .toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
