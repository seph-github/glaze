import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/data/models/follows/follow.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/supabase_services.dart';

part 'follow_repository_provider.g.dart';

@riverpod
FollowRepository followRepository(ref) {
  return FollowRepository(
    supabaseService: ref.watch(supabaseServiceProvider),
  );
}

@riverpod
class FollowUserNotifier extends _$FollowUserNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> onFollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          await ref
              .read(followRepositoryProvider)
              .onFollowUser(followerId: followerId, followingId: followingId);
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }
}

@riverpod
class FetchFollowedUserNotifier extends _$FetchFollowedUserNotifier {
  @override
  FutureOr<List<Follow>?> build(String userId) async =>
      fetchFollowedUsers(userId: userId);

  FutureOr<List<Follow>?> fetchFollowedUsers({required String userId}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          return await ref
              .read(followRepositoryProvider)
              .fetchFollowedUsers(userId: userId);
        },
      );

      return Future.value(state.value);
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
    return state.value;
  }
}

class FollowRepository {
  FollowRepository({
    required this.supabaseService,
  });
  final SupabaseService supabaseService;

  Future<List<Follow>> fetchFollowedUsers({required String userId}) async {
    try {
      final response = await supabaseService.withReturnValuesRpc(
        fn: 'get_user_followed_list',
        params: {
          'params_follower_id': userId,
        },
      );
      return response.map((e) => Follow.fromJson(e)).toList();
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );

      return [];
    }
  }

  Future<void> onFollowUser(
      {required String followerId, required String followingId}) async {
    try {
      await supabaseService.voidFunctionRpc(
        fn: 'following_user',
        params: {
          'params_follower_id': followerId,
          'params_following_id': followingId,
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
  }
}
