import 'package:image_picker/image_picker.dart';

class ContentPickerServices {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return null;

      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> takePhoto({required CameraDevice preferedCameraDevice}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: preferedCameraDevice,
      );
      if (image == null) return null;

      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      return video;
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> takeVideo({required CameraDevice preferedCameraDevice}) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: preferedCameraDevice,
        maxDuration: const Duration(seconds: 15),
      );

      if (video == null) return null;

      return video;
    } catch (e) {
      rethrow;
    }
  }
}
