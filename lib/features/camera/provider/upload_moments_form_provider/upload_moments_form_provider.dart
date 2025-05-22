import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/generate_thumbnail.dart';

part 'upload_moments_form_provider.g.dart';
part 'upload_moments_form_provider.freezed.dart';

@freezed
abstract class UploadMomentFormState with _$UploadMomentFormState {
  const factory UploadMomentFormState({
    @Default(null) String? challengeId,
    @Default(null) String? title,
    @Default(null) String? caption,
    @Default(null) String? category,
    @Default(null) String? filePath,
    @Default(null) File? file,
    @Default(null) File? thumbnail,
    @Default(null) String? location,
    @Default([]) List<String>? tags,
    @Default(null) String? latitude,
    @Default(null) String? longitude,
  }) = _UploadMomentFormState;

  const UploadMomentFormState._();
}

@Riverpod(keepAlive: true)
class UploadMomentForm extends _$UploadMomentForm {
  late final titleController = TextEditingController();
  late final captionController = TextEditingController();
  late final categoryController = TextEditingController();
  late final fileController = TextEditingController();
  late final locationController = TextEditingController();
  late final tagsController = TextEditingController();
  late final latitudeController = TextEditingController();
  late final longitudeController = TextEditingController();
  List<String>? tags;
  File? file;
  File? thumbnail;
  String? challengeId;

  @override
  UploadMomentFormState build() {
    return const UploadMomentFormState(
      challengeId: '',
      title: '',
      caption: '',
      category: '',
      filePath: '',
      location: '',
      tags: [],
      latitude: '',
      longitude: '',
      file: null,
      thumbnail: null,
    );
  }

  void syncControllersToState() {
    state = state.copyWith(
      title: titleController.text.trim(),
      caption: captionController.text.trim(),
      category: categoryController.text.trim(),
      filePath: fileController.text.trim(),
      location: locationController.text.trim(),
      file: file,
      thumbnail: thumbnail,
      tags: tags,
      latitude: latitudeController.text.trim(),
      longitude: longitudeController.text.trim(),
      challengeId: challengeId,
    );
  }

  void clearForm() {
    titleController.clear();
    captionController.clear();
    categoryController.clear();
    fileController.clear();
    locationController.clear();
    file = null;
    thumbnail = null;
    tags = null;
    tagsController.clear();
    latitudeController.clear();
    longitudeController.clear;
    challengeId = null;
    syncControllersToState();
  }

  void clearFile() {
    file = null;
    thumbnail = null;
    fileController.clear();
    syncControllersToState();
  }

  void setChallengeId(String id) {
    challengeId = id;
    syncControllersToState();
  }

  void setFile(File? newFile) async {
    file = newFile;
    fileController.text = newFile!.path.split('/').last;

    if (file != null) {
      thumbnail = await getVideoThumbnail(file!);
    }

    syncControllersToState();
  }

  void setTags() {
    tags = tagsController.text.trim().split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

    syncControllersToState();
  }

  void onDispose() {
    titleController.dispose();
    captionController.dispose();
    categoryController.dispose();
    fileController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    tagsController.dispose();
  }

  bool get hasChanges {
    return titleController.text.isNotEmpty || captionController.text.isNotEmpty || categoryController.text.isNotEmpty || fileController.text.isNotEmpty || file != null;
  }
}
