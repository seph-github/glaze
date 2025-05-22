import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/camera/services/content_picker_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_picker_provider.freezed.dart';
part 'content_picker_provider.g.dart';

@freezed
abstract class ContentPickerState with _$ContentPickerState {
  const factory ContentPickerState({
    @Default(false) bool isLoading,
    @Default(null) XFile? image,
    @Default(null) XFile? identification,
    @Default(null) XFile? video,
    @Default(null) Exception? error,
  }) = _ContentPickerState;

  const ContentPickerState._();
}

@riverpod
class ContentPickerNotifier extends _$ContentPickerNotifier {
  @override
  ContentPickerState build() {
    return const ContentPickerState();
  }

  Future<void> pickIdentificationImage() async {
    try {
      state = state.copyWith(isLoading: true);
      final XFile? image = await ContentPickerServices().pickImage();
      if (image == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(identification: image, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pickImages() async {
    try {
      state = state.copyWith(isLoading: true);
      final XFile? image = await ContentPickerServices().pickImage();
      if (image == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(image: image, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> takePhoto({required CameraDevice prefferedCameraDevice}) async {
    try {
      state = state.copyWith(isLoading: true);
      final XFile? image = await ContentPickerServices().takePhoto(preferedCameraDevice: prefferedCameraDevice);
      if (image == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(image: image, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pickVideos() async {
    try {
      state = state.copyWith(isLoading: true);
      final XFile? video = await ContentPickerServices().pickVideo();
      if (video == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(video: video, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> takeVideo({required CameraDevice preferedCameraDevice}) async {
    try {
      state = state.copyWith(isLoading: true);
      final XFile? video = await ContentPickerServices().takeVideo(preferedCameraDevice: preferedCameraDevice);
      if (video == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(video: video, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
