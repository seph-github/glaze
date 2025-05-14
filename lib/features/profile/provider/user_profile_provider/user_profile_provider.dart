import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/secure_storage_services.dart';
import '../../models/profile/profile.dart';
import '../../services/profile_services.dart';

part 'user_profile_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Profile?> userProfile(Ref ref) async {
  // Load cached Profile from secure storage using the generic cache
  final cached = await SecureCache.load<Profile>(
    'user_profile',
    (json) => Profile.fromJson(json),
  );

  final session = Supabase.instance.client.auth.currentSession;

  if (session?.user == null) {
    return cached;
  }

  try {
    // Fetch latest profile from server
    if (session == null) {
      return null;
    }

    final fetched = await ProfileServices().fetchUserProfile(session.user.id);

    // Save to secure storage using generic save
    await SecureCache.save(
      'user_profile',
      fetched,
      fetched!.toJson,
    );

    return fetched;
  } catch (_) {
    // Fallback to cache on error
    return cached;
  }
}
