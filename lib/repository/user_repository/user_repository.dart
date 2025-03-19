import 'package:glaze/core/services/supabase_services.dart';
import 'package:glaze/repository/auth_service/auth_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/glaze/glaze_model.dart';
import '../../data/models/user/user_model.dart';
import '../../data/models/video/video_model.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return UserRepository(supabaseService: supabaseService);
}

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<UserModel?> build() async {
    final user = await ref.watch(authServiceProvider).getCurrentUser();
    return ref.watch(userRepositoryProvider).fetchUser(
          user: user,
        );
  }
}

class UserRepository {
  const UserRepository({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<UserModel?> fetchUser({required User? user}) async {
    try {
      final response = await supabaseService.findById(
        table: 'users',
        id: user!.id,
      );

      if (response.isNotEmpty) {
        final glazedResponse = await supabaseService.select(
          table: 'glazes',
          filterColumn: 'user_id',
          filterValue: user.id,
        );

        final videoResponse = await supabaseService.select(
          table: 'videos',
          filterColumn: 'user_id',
          filterValue: user.id,
        );

        return UserModel.fromJson(response).copyWith(
          glazes: glazedResponse.map((e) => GlazeModel.fromJson(e)).toList(),
          videos: videoResponse.map((e) => VideoModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return null;
  }
}
