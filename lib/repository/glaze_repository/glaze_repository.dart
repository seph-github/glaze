import 'package:glaze/core/services/supabase_services.dart';
import 'package:glaze/repository/auth_service/auth_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/glaze/glaze_model.dart';

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
    final user = await ref.watch(authServiceProvider).getCurrentUser();
    return ref.watch(glazeRepositoryProvider).fetchUserGlaze(
          userId: user!.id,
        );
  }
}

class GlazeRepository {
  GlazeRepository({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  Future<void> onGlaze(
      {required String videoId, required String userId}) async {
    try {
      print('called');
      await _supabaseService.toggleRpc(
        fn: 'toggle_glaze',
        params: {
          'p_video_id': videoId,
          'p_user_id': userId,
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
      return response
          .map<GlazeModel>((json) => GlazeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('GlazeRepository.fetchUserGlaze: $e');
    }
  }
}
