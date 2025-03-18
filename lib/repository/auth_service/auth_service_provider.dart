import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/entities/user_entity.dart';
import '../supabase_client_provider/supabase_client_provider.dart';

part 'auth_service_provider.g.dart';

@riverpod
AuthService authService(ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthService(supabaseClient: supabaseClient);
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  FutureOr build() => null;

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
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
    state = const AsyncLoading();
    try {
      state = await AsyncValue.guard(
        () => ref.read(authServiceProvider).signUpWithEmailPassword(
            email: email, password: password, username: username),
      );
    } catch (e, _) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }
}

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

  Future<User?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;

      if (session == null) return null;

      return supabaseClient.auth.currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return supabaseClient.auth.onAuthStateChange;
  }
}

@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(authServiceProvider).onAuthStateChange();
}
