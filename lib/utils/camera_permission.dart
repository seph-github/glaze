import 'package:permission_handler/permission_handler.dart';

class CameraPermission {
  // Method to check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  // Method to request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    switch (status) {
      case PermissionStatus.granted:
        // The permission is granted
        return true;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        // The permission is permanently denied
        openAppSettings();
        return false;
      case PermissionStatus.restricted:
        // The permission is restricted
        return false;
      case PermissionStatus.limited:
        // The permission is limited
        return false;
      default:
        return false;
    }
  }
}
