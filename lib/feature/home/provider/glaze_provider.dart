import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
import 'package:glaze/feature/home/services/glaze_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/glaze.dart';

part 'glaze_provider.freezed.dart';
part 'glaze_provider.g.dart';

@freezed
abstract class GlazeState with _$GlazeState {
  const factory GlazeState({
    @Default([]) List<Glaze>? glazes,
    @Default(null) String? response,
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
    @Default(0) int glazesCount,
  }) = _GlazeState;

  const GlazeState._();
}

@riverpod
class GlazeNotifier extends _$GlazeNotifier {
  @override
  GlazeState build() {
    return const GlazeState();
  }

  void setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<void> onGlazed({required String videoId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final User? user = AuthServices().currentUser;
      await GlazeServices().onGlazed(videoId: videoId, userId: user?.id ?? '');

      state = state.copyWith(isLoading: false, response: 'Success');
    } catch (e) {
      setError(e);
    }
  }

  Future<void> fetchUserGlazes() async {
    state = state.copyWith(isLoading: true);
    try {
      final User? user = AuthServices().currentUser;

      final glazes = await GlazeServices().fetchUserGlazes(userId: user?.id ?? '');

      state = state.copyWith(glazes: glazes, isLoading: false);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> getVideoGlazeCount(String videoId) async {
    state = state.copyWith(isLoading: true);
    try {
      print('calling notifier $videoId');
      final count = await GlazeServices().getVideoGlazeCount(videoId);

      state = state.copyWith(isLoading: false, glazesCount: count);
    } catch (e) {
      setError(e);
    }
  }
}
