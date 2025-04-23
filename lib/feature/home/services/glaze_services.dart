import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/glaze.dart';

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
      final response = await _supabaseClient.from('glazes').select('video_id').eq('video_id', videoId).count();

      print('video response ${response.count}');
      return response.count;
    } catch (e) {
      rethrow;
    }
  }
}
