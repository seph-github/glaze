import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/auth/services/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';

import '../../../challenges/services/challenge_services.dart';
import '../../../home/models/video_content/video_content.dart';
import '../../../home/services/video_content_services.dart';
import '../../../moments/providers/upload_moments_form_provider/upload_moments_form_provider.dart';
import '../../../profile/provider/profile_provider/profile_provider.dart';

part 'camera_upload_content_provider.freezed.dart';
part 'camera_upload_content_provider.g.dart';

@freezed
abstract class CameraUploadContentState with _$CameraUploadContentState {
  const factory CameraUploadContentState({
    @Default(null) VideoContent? video,
    @Default('') String? responseMessage,
    @Default(false) isLoading,
    @Default(null) dynamic error,
  }) = _CameraUploadContentState;

  const CameraUploadContentState._();
}

@riverpod
class CameraUploadContentNotifier extends _$CameraUploadContentNotifier {
  @override
  CameraUploadContentState build() {
    return const CameraUploadContentState();
  }

  final VideoContentServices _videoServices = VideoContentServices();

  void _setError(dynamic error) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<void> uploadVideoContent({String? challengeId}) async {
    state = state.copyWith(isLoading: true, error: null, responseMessage: null);
    try {
      final formState = ref.watch(uploadMomentFormProvider);

      final User? user = AuthServices().currentUser;

      final response = await _videoServices.uploadVideoContent(
        form: formState,
        userId: user!.id,
      );

      if (challengeId != null) {
        await ChallengeServices().submitChallengeEntry(userId: user.id, challengeId: challengeId, videoId: response.id);
      }

      await ref.read(profileNotifierProvider.notifier).fetchProfile(user.id);

      const resMessage = 'Success Uploaded Video';

      state = state.copyWith(isLoading: false, responseMessage: resMessage, video: response);
    } catch (e) {
      _setError(e);
    }
  }
}
