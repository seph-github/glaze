import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/enum/profile_type.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return authResponse;
    } on AuthApiException catch (e) {
      print('error signing in: $e');
      throw Exception('SignIn: $e');
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
    ProfileType? profileType,
  }) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'role': profileType?.value,
        },
      );

      return authResponse;
    } on AuthApiException catch (e) {
      return throw AuthApiException(e.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> anonymousSignin() async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signInAnonymously();

      // final int tempUserId = createRandomNumber();

      // await supabaseService.update(
      //   id: authResponse.user!.id,
      //   table: 'profiles',
      //   data: {
      //     'username_id': tempUserId,
      //   },
      // );

      return authResponse;
    } on AuthApiException catch (e) {
      throw AuthApiException(e.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthApiException catch (e) {
      throw Exception('SignOut: $e');
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return _supabase.auth.onAuthStateChange;
  }

  int createRandomNumber() {
    final random = Random();
    return random.nextInt(90000000) + 10000000;
  }
}
