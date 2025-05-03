import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/enum/profile_type.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

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
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    required String password,
    required String username,
    ProfileType? profileType,
  }) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        phone: phone,
        password: password,
        data: {
          'username': username,
          'role': profileType?.value,
        },
        channel: OtpChannel.sms,
      );

      return authResponse;
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithPhone(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyPhone({required String phone, required String token}) async {
    try {
      final AuthResponse authtResponse = await _supabase.auth.verifyOTP(
        token: token,
        phone: phone,
        type: OtpType.sms,
      );

      return authtResponse;
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<AuthResponse> anonymousSignin() async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signInAnonymously(data: {
        'role': ProfileType.user.value,
      });

      return authResponse;
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthApiException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email, redirectTo: 'myapp://auth/auth/reset-password');
    } on AuthApiException catch (e) {
      log('Error AuthApiException resetting password: $e');
      rethrow;
    } on AuthException catch (e) {
      log('Error AuthException resetting password: $e');
      rethrow;
    } catch (e) {
      log('Error resetting password: $e');
      rethrow;
    }
  }

  Future<UserResponse> updatePassword({
    String? email,
    String? password,
    String? token,
    String? tokenHash,
  }) async {
    try {
      final authResponse = await _supabase.auth.verifyOTP(type: OtpType.email, tokenHash: tokenHash);

      if (authResponse.session!.accessToken.isNotEmpty && !authResponse.session!.isExpired && authResponse.user != null) {
        final UserAttributes userAttributes = UserAttributes(
          email: email,
          password: password,
        );

        return await _supabase.auth.updateUser(userAttributes);
      }

      throw Exception('Session is invalid');
    } on AuthApiException catch (e) {
      log('Auth API exception $e');
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return _supabase.auth.onAuthStateChange;
  }
}
