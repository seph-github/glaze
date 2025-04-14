import 'dart:developer';

import 'package:glaze/feature/moments/models/challenge.dart';
import 'package:glaze/feature/moments/models/enrolled_challenge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MomentsServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Challenge>> fetchAllChallenges() async {
    try {
      final response = await _supabaseClient.from('challenges').select();
      final raw = response as List<dynamic>;
      final value = raw
          .map((challenge) =>
              Challenge.fromJson(challenge as Map<String, dynamic>))
          .toList();
      return value;
    } catch (e) {
      log('❌ MomentsServices.fetchAllChallenges: $e');
      rethrow;
    }
  }

  Future<List<Challenge>> fetchUpcomingChallenges(String userId) async {
    try {
      // 1. Get all enrollments for the user
      final response = await _supabaseClient
          .from('challenge_enrollments')
          .select()
          .eq('user_id', userId);

      if (response.isNotEmpty) {
        final raw = response as List<dynamic>;

        final List<EnrolledChallenge> enrolledChallenges =
            raw.map((enroll) => EnrolledChallenge.fromJson(enroll)).toList();

        final challengeIds =
            enrolledChallenges.map((e) => '"${e.challengeId}"').join(',');
        final filterString = '($challengeIds)';

        if (challengeIds.isEmpty) return [];

        // 2. Get challenges by ID list
        final challengeResponse = await _supabaseClient
            .from('challenges')
            .select()
            .filter('id', 'in', filterString);

        // log('Challenge Response: $challengeResponse');

        if (challengeResponse.isNotEmpty) {
          final rawChallenges = challengeResponse as List<dynamic>;

          final List<Challenge> challenges = rawChallenges
              .map((challenge) => Challenge.fromJson(challenge))
              .toList();

          log('✅ Enrolled Challenges: $challenges');

          return challenges;
        }
      }

      return [];
    } catch (e) {
      log('❌ MomentsServices.fetchUpcomingChallenges: $e');
      rethrow;
    }
  }
}
