import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/enum/profile_type.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(null) AuthResponse? authResponse,
    @Default(false) bool isLoading,
    @Default(false) bool otpSent,
    Exception? error,
  }) = _AuthState;

  const AuthState._();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final authResponse = await AuthServices().signInWithEmailPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(authResponse: authResponse, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }

  Future<void> signUp({
    String? email,
    String? phone,
    required String password,
    required String username,
    ProfileType? profileType,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final authResponse = await AuthServices().signUp(
        email: email,
        password: password,
        username: username,
        profileType: profileType,
      );
      state = state.copyWith(authResponse: authResponse, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }

  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(isLoading: true);
    try {
      await AuthServices().signInWithPhone(phone);
      state = state.copyWith(isLoading: false, otpSent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }

  Future<void> verifyPhone({required String phone, required String token}) async {
    state = state.copyWith(isLoading: true);
    try {
      final authResponse = await AuthServices().verifyPhone(
        phone: phone,
        token: token,
      );
      state = state.copyWith(authResponse: authResponse, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }

  Future<void> anonymousSignin() async {
    state = state.copyWith(isLoading: true);
    try {
      final authResponse = await AuthServices().anonymousSignin();
      state = state.copyWith(authResponse: authResponse, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await AuthServices().signOut();
      state = state.copyWith(authResponse: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e as Exception);
    }
  }
}
