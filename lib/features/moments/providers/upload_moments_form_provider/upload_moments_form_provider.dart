import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_moments_form_provider.g.dart';
part 'upload_moments_form_provider.freezed.dart';

@freezed
abstract class UploadMomentFormState with _$UploadMomentFormState {
  const factory UploadMomentFormState({
    @Default(null) String? title,
    @Default(null) String? caption,
    @Default(null) String? category,
    @Default(null) String? filePath,
    @Default(null) File? file,
    @Default(null) File? thumbnail,
  }) = _UploadMomentFormState;

  const UploadMomentFormState._();
}

@Riverpod(keepAlive: true)
class UploadMomentForm extends _$UploadMomentForm {
  late final titleController = TextEditingController();
  late final captionController = TextEditingController();
  late final categoryController = TextEditingController();
  late final fileController = TextEditingController();
  File? file;
  File? thumbnail;

  @override
  UploadMomentFormState build() {
    return const UploadMomentFormState(
      title: '',
      caption: '',
      category: '',
      filePath: '',
    );
  }

  void syncControllersToState() {
    state = state.copyWith(
      title: titleController.text.trim(),
      caption: captionController.text.trim(),
      category: categoryController.text.trim(),
      filePath: fileController.text.trim(),
      file: file,
      thumbnail: thumbnail,
    );
  }

  void clearForm() {
    titleController.clear();
    captionController.clear();
    categoryController.clear();
    fileController.clear();
    file = null;
    thumbnail = null;
    syncControllersToState();
  }

  void clearFile() {
    file = null;
    thumbnail = null;
    fileController.clear();
    syncControllersToState();
  }

  void setFile(File? newFile) {
    file = newFile;
    fileController.text = newFile!.path.split('/').last;
    syncControllersToState();
  }

  void setThumbnail(File? newThumbnail) {
    thumbnail = newThumbnail;
    syncControllersToState();
  }

  void onDispose() {
    titleController.dispose();
    captionController.dispose();
    categoryController.dispose();
    fileController.dispose();
  }

  bool get hasChanges {
    return titleController.text.isNotEmpty || captionController.text.isNotEmpty || categoryController.text.isNotEmpty || fileController.text.isNotEmpty || file != null;
  }
}
