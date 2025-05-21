import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/challenges/services/challenge_services.dart';
import 'package:glaze/features/home/services/video_content_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

import '../../auth/services/auth_services.dart';
import '../../moments/providers/upload_moments_form_provider/upload_moments_form_provider.dart';
import '../models/challenge_entry/challenge_entry.dart';

part 'challenge_provider.freezed.dart';
part 'challenge_provider.g.dart';

@freezed
class ChallengeState with _$ChallengeState {
  const factory ChallengeState({
    @Default([]) List<ChallengeEntry> entries,
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
  }) = _ChallangeState;

  factory ChallengeState.fromJson(Map<String, dynamic> json) => _$ChallengeStateFromJson(json);
}

@riverpod
class ChallengeNotifier extends _$ChallengeNotifier {
  @override
  ChallengeState build() {
    return const ChallengeState();
  }

  final ChallengeServices _challengeServices = ChallengeServices();

  void setError(dynamic e) {
    state = state.copyWith(error: null);
    state = state.copyWith(isLoading: false, error: e);
  }

  Future<void> getChallengeEntries(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _challengeServices.getChallengeEntries(id);

      if (response.isEmpty) {
        state = state.copyWith(entries: [], isLoading: false);
      }

      state = state.copyWith(isLoading: false, entries: response);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> submitChallengeEntry({
    required String challengeId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final formState = ref.watch(uploadMomentFormProvider);

      final User? user = AuthServices().currentUser;
      final response = await VideoContentServices().uploadVideoContent(
        form: formState,
        // file: formState.file!,
        userId: user!.id,
        // title: formState.title!,
        // caption: formState.caption!,
        // category: formState.category!,
        // thumbnail: formState.thumbnail!,
      );

      if (response is Exception) return;

      await _challengeServices.submitChallengeEntry(userId: user.id, challengeId: challengeId, videoId: response.id);
    } catch (e) {
      setError(e);
    }
  }
}
