import 'package:glaze/features/challenges/models/challenge/challenge.dart';
import 'package:glaze/features/home/models/video_content/video_content.dart';
import 'package:glaze/features/moments/models/enrolled_challenge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MomentsServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<VideoContent>> search({
    String? keywords,
    String? filterBy,
    int? pageLimit,
    int? pageOffset,
  }) async {
    try {
      final Map<String, dynamic> requestParams = {
        'search_text': keywords,
        'filter_category': filterBy,
        'page_limit': pageLimit,
        'page_offset': pageOffset,
      }..removeWhere(
          (key, value) => value == null || value == '',
        );

      final response = await _supabaseClient.rpc(
        'search_videos',
        params: requestParams,
      );

      if (response == null) return [];

      final raw = response as List<dynamic>;

      return raw.map((e) => VideoContent.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Challenge>> fetchAllChallenges() async {
    try {
      final response = await _supabaseClient.from('challenges').select();
      final raw = response as List<dynamic>;

      final value = raw.map((challenge) => Challenge.fromJson(challenge as Map<String, dynamic>)).toList();
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Challenge>> fetchUpcomingChallenges(String userId) async {
    try {
      final response = await _supabaseClient.from('challenge_enrollments').select().eq('user_id', userId);

      if (response.isNotEmpty) {
        final raw = response as List<dynamic>;

        final List<EnrolledChallenge> enrolledChallenges = raw.map((enroll) => EnrolledChallenge.fromJson(enroll)).toList();

        final challengeIds = enrolledChallenges.map((e) => '"${e.challengeId}"').join(',');
        final filterString = '($challengeIds)';

        if (challengeIds.isEmpty) return [];

        final challengeResponse = await _supabaseClient.from('challenges').select().filter('id', 'in', filterString);

        if (challengeResponse.isNotEmpty) {
          final rawChallenges = challengeResponse as List<dynamic>;

          final List<Challenge> challenges = rawChallenges.map((challenge) => Challenge.fromJson(challenge)).toList();

          return challenges;
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitChallengeEntry({
    required String userId,
    required String challengeId,
    required String videoId,
  }) async {
    try {
      await _supabaseClient.rpc(
        'submit_challenge_entry',
        params: {
          'p_user_id': userId,
          'p_challenge_id': challengeId,
          'p_video_id': videoId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
