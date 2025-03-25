import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/core/services/supabase_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authService(ref) {
  final supabaseClient = ref.watch(supabaseServiceProvider);
  return AuthRepository(supabaseService: supabaseClient);
}

@riverpod
class LoggedInUserNotifier extends _$LoggedInUserNotifier {
  @override
  FutureOr<User?> build() => ref.watch(authServiceProvider).getCurrentUser();
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  FutureOr build() => null;

  Future<void> login({required String email, required String password}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () => ref
            .read(authServiceProvider)
            .signInWithEmailPassword(email: email, password: password),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }
}

@riverpod
class SignupNotifier extends _$SignupNotifier {
  @override
  FutureOr build() => null;

  Future<void> signup(
      {required String email,
      required String password,
      required String username}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () => ref.read(authServiceProvider).signUpWithEmailPassword(
            email: email, password: password, username: username),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }
}

@riverpod
class LogoutNotifier extends _$LogoutNotifier {
  @override
  FutureOr build() async => null;

  Future<void> logout() async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async => await ref.read(authServiceProvider).signOut(),
      );
    } catch (e) {
      throw Exception('LogoutNotifier.logout: $e');
    }
  }
}

class AuthRepository {
  AuthRepository({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<AuthResponse> signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final result = await supabaseService.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailPassword({
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

      // print('User ${authResponse.user}');

      await supabaseService.update(
        id: authResponse.user!.id,
        table: 'profiles',
        data: {
          'username': username,
        },
      );
    } catch (e) {
      throw Exception('SignUpRepository.signUp: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseService.supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final session = supabaseService.supabase.auth.currentSession;

      if (session == null) return null;

      return supabaseService.supabase.auth.currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return supabaseService.supabase.auth.onAuthStateChange;
  }
}

@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(authServiceProvider).onAuthStateChange();
}
