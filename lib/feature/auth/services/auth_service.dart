import 'package:glaze/models/user/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      print('Result $result');
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
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final usersDb = supabaseClient.from('users');

      // final user = UserModel(
      //   email: email,
      //   username: username,

      // );

      await usersDb.insert({UserModel});
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
