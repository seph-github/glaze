import 'package:glaze/feature/home/models/glaze_stats/glaze_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/glaze/glaze.dart';

class GlazeServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> onGlazed({required String videoId, required String userId}) async {
    try {
      await _supabaseClient.rpc(
        'toggle_glaze',
        params: {
          'p_user_id': userId,
          'p_video_id': videoId,
        },
      );
    } on PostgrestException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Glaze>> fetchUserGlazes({required String userId}) async {
    try {
      final response = await _supabaseClient.from('glazes').select().eq('user_id', userId);

      final raw = response as List<dynamic>;

      return raw
          .map<Glaze>(
            (json) => Glaze.fromJson(json),
          )
          .toList();
    } on PostgrestException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('GlazeRepository.fetchUserGlaze: $e');
    }
  }

  Future<int> getVideoGlazeCount(String videoId) async {
    try {
      final response = await _supabaseClient.from('videos').select('glazes_count').eq('id', videoId).single();

      return response['glazes_count'];
    } catch (e) {
      rethrow;
    }
  }

  Future<GlazeStats> getVideoGlazeStats({required String videoId, required String userId}) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_video_glaze_stats',
        params: {
          'vid': videoId,
          'uid': userId,
        },
      );

      final raw = response as List<dynamic>;

      if (raw.isEmpty) {
        return const GlazeStats(count: 0, hasGlazed: false);
      }

      final stat = response.first;
      return GlazeStats(
        count: stat['total_glazes'],
        hasGlazed: stat['has_glazed'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
