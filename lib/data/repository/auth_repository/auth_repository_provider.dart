import 'dart:math' hide log;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glaze/core/services/supabase_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result_handler/results.dart';

part 'auth_repository_provider.g.dart';

@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(authServiceProvider).onAuthStateChange();
}

@riverpod
AuthRepository authService(ref) {
  final supabaseClient = ref.watch(supabaseServiceProvider);
  return AuthRepository(supabaseService: supabaseClient);
}

@riverpod
class LoggedInUserNotifier extends _$LoggedInUserNotifier {
  @override
  FutureOr<Result<User?, Exception>> build() async {
    try {
      final result = await ref.watch(authServiceProvider).getCurrentUser();
      return Success(result);
    } catch (e) {
      return Failure(e as Exception);
    }
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  FutureOr<Result<AuthResponse, Exception>?> build() async => null;

  Future<Result<AuthResponse, Exception>> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ref.read(authServiceProvider).signInWithEmailPassword(
            email: email,
            password: password,
          ),
    );
    return Future.value(state.value);
  }
}

@riverpod
class SignupNotifier extends _$SignupNotifier {
  @override
  FutureOr<Result<AuthResponse, Exception>?> build() async => null;

  Future<Result<AuthResponse, Exception>> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ref.read(authServiceProvider).signUpWithEmailPassword(
            email: email,
            password: password,
            username: username,
          ),
    );
    return Future.value(state.value);
  }
}

@riverpod
class AnonymousSigninNotifier extends _$AnonymousSigninNotifier {
  @override
  FutureOr<Result<AuthResponse, Exception>?> build() => null;

  Future<Result<AuthResponse, Exception>> anonymousSignin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ref.read(authServiceProvider).anonymousSignin(),
    );

    return Future.value(state.value);
  }
}

@riverpod
class LogoutNotifier extends _$LogoutNotifier {
  @override
  FutureOr build() async => null;

  Future<void> logout() async {
    if (state.isLoading) return;

    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async => await ref.read(authServiceProvider).signOut(),
      );
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

class AuthRepository {
  AuthRepository({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<Result<AuthResponse, Exception>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse authResponse =
          await supabaseService.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return Success<AuthResponse, Exception>(authResponse);
    } on AuthApiException catch (e) {
      return Failure<AuthResponse, Exception>(e);
    }
  }

  Future<Result<AuthResponse, Exception>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final AuthResponse authResponse =
          await supabaseService.supabase.auth.signUp(
        email: email,
        password: password,
      );

      await supabaseService.update(
        id: authResponse.user!.id,
        table: 'profiles',
        data: {
          'username': username,
        },
      );

      return Success<AuthResponse, Exception>(authResponse);
    } on AuthApiException catch (e) {
      return Failure<AuthResponse, Exception>(e);
    }
  }

  Future<Result<AuthResponse, Exception>> anonymousSignin() async {
    try {
      final AuthResponse authResponse =
          await supabaseService.supabase.auth.signInAnonymously();

      final int tempUserId = createRandomNumber();

      await supabaseService.update(
        id: authResponse.user!.id,
        table: 'profiles',
        data: {
          'username_id': tempUserId,
        },
      );

      return Success<AuthResponse, Exception>(authResponse);
    } on AuthApiException catch (e) {
      return Failure<AuthResponse, Exception>(e);
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseService.supabase.auth.signOut();
    } on AuthApiException catch (e) {
      throw Exception('SignOut: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final session = supabaseService.supabase.auth.currentSession;

      if (session == null) return null;

      return supabaseService.supabase.auth.currentUser;
    } catch (e) {
      throw Exception('AuthRepository.getCurrentUser: $e');
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return supabaseService.supabase.auth.onAuthStateChange;
  }

  int createRandomNumber() {
    final random = Random();
    return random.nextInt(90000000) + 10000000;
  }
}
