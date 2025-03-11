import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../entities/user_entity.dart';

class AuthService {
  AuthService({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  Future<AuthResponse> signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final result = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailPassword(
      {required String email,
      required String password,
      required String username}) async {
    try {
      final userResult = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final usersDb = supabaseClient.from('users');

      final user = UserEntity(
        id: userResult.user!.id,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );

      await usersDb.insert(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
