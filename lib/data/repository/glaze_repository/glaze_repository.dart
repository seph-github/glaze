import 'package:glaze/core/services/supabase_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/auth/services/auth_services.dart';
import '../../models/glaze/glaze_model.dart';

part 'glaze_repository.g.dart';

@riverpod
GlazeRepository glazeRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return GlazeRepository(supabaseService: supabaseService);
}

@riverpod
class GlazeNotifier extends _$GlazeNotifier {
  @override
  FutureOr<List<GlazeModel>> build() async {
    final user = AuthServices().currentUser;
    if (user == null) return [];
    return ref.watch(glazeRepositoryProvider).fetchUserGlaze(
          userId: user.id,
        );
  }
}

class GlazeRepository {
  GlazeRepository({required SupabaseService supabaseService}) : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  Future<void> onGlaze({required String videoId, required String userId}) async {
    try {
      await _supabaseService.voidFunctionRpc(
        fn: 'toggle_glaze',
        params: {
          'p_user_id': userId,
          'p_video_id': videoId,
        },
      );
    } catch (e) {
      throw Exception('GlazeRepository.onGlaze: $e');
    }
  }

  FutureOr<List<GlazeModel>> fetchUserGlaze({required String userId}) async {
    try {
      final response = await _supabaseService.select(
        table: 'glazes',
        filterColumn: 'user_id',
        filterValue: userId,
      );
      return response.map<GlazeModel>((json) => GlazeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('GlazeRepository.fetchUserGlaze: $e');
    }
  }
}
