import 'dart:developer';

import 'package:glaze/features/challenges/models/challenge_entry/challenge_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeServices {
  ChallengeServices();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ChallengeEntry>> getChallengeEntries(String id) async {
    try {
      final response = await _supabase.rpc(
        'get_challenge_entries',
        params: {
          'p_challenge_id': id,
        },
      );

      log('Get Challenge Entries $response');

      if (response == null) return [];

      final raw = response as List<dynamic>;

      return raw.map((entry) => ChallengeEntry.fromJson(entry)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
