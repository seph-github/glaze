import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/core/services/supabase_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user/user_model.dart';
import '../auth_repository/auth_repository_provider.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return UserRepository(supabaseService: supabaseService);
}

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<UserModel?> build() async {
    return fetchUser();
  }

  FutureOr<UserModel?> fetchUser() async {
    try {
      state = const AsyncLoading();

      state = await AsyncValue.guard(
        () async {
          final user = await ref.watch(authServiceProvider).getCurrentUser();

          final UserModel? userModel =
              await ref.watch(userRepositoryProvider).fetchUser(
                    id: user?.id,
                  );

          return userModel;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }

    return state.value;
  }
}

@riverpod
class GetUserProfileNotifier extends _$GetUserProfileNotifier {
  @override
  FutureOr<UserModel?> build(String id) async => fetchUsersProfile(id: id);

  FutureOr<UserModel?> fetchUsersProfile({required String id}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          final userModel =
              await ref.watch(userRepositoryProvider).fetchUsersProfile(
                    id: id,
                  );

          return userModel;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
    return state.value;
  }
}

class UserRepository {
  const UserRepository({required this.supabaseService});

  final SupabaseService supabaseService;

  FutureOr<UserModel?> fetchUser({required String? id}) async {
    try {
      if (id == null) return null;

      final response = await supabaseService.withReturnValuesRpc(
        fn: 'find_user_by_id',
        params: {'params_user_id': id},
      );

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<UserModel?> fetchUsersProfile({required String id}) async {
    try {
      final response = await supabaseService.withReturnValuesRpc(
          fn: 'find_user_by_id', params: {'params_user_id': id});

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }
}
