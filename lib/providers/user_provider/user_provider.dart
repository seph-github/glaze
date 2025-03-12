import 'package:glaze/feature/auth/providers/auth_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_provider.g.dart';

@riverpod
Future<User?> user(ref) {
  return ref.watch(authServiceProvider).getCurrentUser();
}
