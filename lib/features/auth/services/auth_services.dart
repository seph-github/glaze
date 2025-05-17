import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Map<String, dynamic> rawUserMetaData({String? username, ProfileType? profileType}) {
    return {
      'username': username,
      'role': profileType?.value,
      'is_onboarding_complete': false,
      'is_profile_complete': false,
    };
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
        data: rawUserMetaData(profileType: profileType!),
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
        data: rawUserMetaData(
          profileType: ProfileType.user,
        ),
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
      final AuthResponse authResponse = await _supabase.auth.signInAnonymously(
        data: rawUserMetaData(profileType: ProfileType.user),
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

  Future<AuthResponse> signInWithGoogle() async {
    try {
      const String webClientId = String.fromEnvironment('webClientId', defaultValue: '');
      const iosClientId = String.fromEnvironment('iosClientId', defaultValue: '');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return throw Exception(
          PlatformException(message: 'Sign in cancelled', code: '1000'),
        );
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth
          .signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      )
          .then((value) async {
        if (!value.user!.userMetadata!.containsKey('is_onboarding_complete')) {
          log('has no is onboarding');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'is_onboarding_complete': false
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('is_profile_complete')) {
          log('has no  profile complete');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'is_profile_complete': false
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('role')) {
          log('has no is role');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'role': ProfileType.user.value
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('is_onboarding_complete') && !value.user!.userMetadata!.containsKey('is_profile_complete') && !value.user!.userMetadata!.containsKey('role')) {
          log('has nothing');
          await _supabase.auth.updateUser(
            UserAttributes(data: rawUserMetaData(profileType: ProfileType.user)),
          );
        }
      });

      log('google sign in response ${response.user}');

      return response;
    } catch (e) {
      log('google sign in error $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Could not find ID Token from generated credential.');
      }
      final response = await _supabase.auth
          .signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      )
          .then((value) async {
        if (!value.user!.userMetadata!.containsKey('is_onboarding_complete')) {
          log('has no is onboarding');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'is_onboarding_complete': false
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('is_profile_complete')) {
          log('has no  profile complete');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'is_profile_complete': false
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('role')) {
          log('has no is role');
          await _supabase.auth.updateUser(
            UserAttributes(data: {
              'role': ProfileType.user.value
            }),
          );
        }
        if (!value.user!.userMetadata!.containsKey('is_onboarding_complete') && !value.user!.userMetadata!.containsKey('is_profile_complete') && !value.user!.userMetadata!.containsKey('role')) {
          log('has nothing');
          await _supabase.auth.updateUser(
            UserAttributes(data: rawUserMetaData(profileType: ProfileType.user)),
          );
        }
      });

      log('Apple sign in response ${response.user}');

      return response;
    } catch (e) {
      log('Apple sign in error $e');
      rethrow;
    }
  }

  Future<void> changeCodeToSession(String token) async {
    try {
      final response = await _supabase.auth.exchangeCodeForSession(token);

      log('response $response');
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return _supabase.auth.onAuthStateChange;
  }

// Function to generate a random code verifier

  String generateCodeVerifier() {
    final random = Random.secure();

    const length = 128;
// Length of the code verifier

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String createCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);

    final digest = sha256.convert(bytes);

    return base64Url.encode(digest.bytes).replaceAll('=', '');
// Remove padding
  }

  Future<void> storeCodeVerifier() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

// Generate code verifier

    final codeVerifier = generateCodeVerifier();

// Store in local storage

    await prefs.setString('supabase.auth.token-code-verifier', codeVerifier);
  }
}
