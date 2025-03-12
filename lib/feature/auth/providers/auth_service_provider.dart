import 'package:glaze/feature/auth/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/supabase_client_provider/supabase_client_provider.dart';

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
    state = await AsyncValue.guard(
      () => ref
          .read(authServiceProvider)
          .signInWithEmailPassword(email: email, password: password),
    );
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
      rethrow;
    }
  }
}
