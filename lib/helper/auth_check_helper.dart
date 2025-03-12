import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/auth/providers/auth_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCheckHelper {
  static Future<bool> isLoggedIn({required WidgetRef ref}) async {
    final User? user = await ref.read(authServiceProvider).getCurrentUser();

    if (user == null) return false;

    return true;
  }
}
