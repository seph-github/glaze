import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_picker_provider.g.dart';

@riverpod
class FilePickerNotifier extends _$FilePickerNotifier {
  @override
  Future<File?> build() async => null;

  Future<File?> pickFile({FileType? type}) async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: type ?? FileType.any);

    if (pickedFile == null) {
      return null;
    }

    return File(pickedFile.files.single.path!);
  }
}

Future<bool> requestPermissions() async {
  final permissionStatus = await Permission.photos.status;

  switch (permissionStatus) {
    case PermissionStatus.denied:
    case PermissionStatus.permanentlyDenied:
      await Permission.photos.request();

      if (permissionStatus != PermissionStatus.granted) {
        Permission.photos.onPermanentlyDeniedCallback(
          () async {
            await Permission.photos.request();
          },
        ).onLimitedCallback(
          () async {
            await Permission.photos.request();
          },
        ).onRestrictedCallback(
          () async {
            await Permission.photos.request();
          },
        ).onProvisionalCallback(
          () async {
            await Permission.photos.request();
          },
        ).onDeniedCallback(
          () async {
            await Permission.photos.request();
          },
        );
      }
      break;
    case PermissionStatus.limited:
    case PermissionStatus.provisional:
    case PermissionStatus.restricted:
    case PermissionStatus.granted:
      break;
  }

  return (permissionStatus == PermissionStatus.limited ||
      permissionStatus == PermissionStatus.provisional ||
      permissionStatus == PermissionStatus.restricted ||
      permissionStatus == PermissionStatus.granted);
}
