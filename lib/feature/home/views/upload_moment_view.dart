import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/drop_downs/custom_drop_down_menu.dart';
import '../../../components/inputs/input_field.dart';
import '../../../repository/file_picker/file_picker_provider.dart';
import '../../../repository/video_repository/video_repository.dart';

class UploadMoment extends HookWidget {
  UploadMoment({
    super.key,
  });

  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = useTextEditingController();
    final optionController = useTextEditingController();

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(filePickerNotifierProvider).value;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Upload your moment',
              ),
              const Text(
                'Share your talent with the community!',
              ),
              const SizedBox(
                height: 16.0,
              ),
              InputField.text(
                controller: titleController,
                hintText: 'Video Title',
              ),
              const SizedBox(
                height: 16.0,
              ),
              CustomDropDownMenu(
                menus: options,
                hintText: 'Select an option',
                onSelected: (value) {
                  optionController.text = value ?? '';
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              FocusButton(
                onTap: () async => await ref
                    .read(filePickerNotifierProvider.notifier)
                    .pickFile(),
                helper: const Text('Maximum file size: 100MB'),
                child: Row(
                  children: [
                    const Text('Choose file'),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Text(
                      state == null
                          ? ''
                          : 'File to be upload size ${(state.lengthSync() / 1024).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Upload Moment',
                onPressed: () async {
                  final file = ref.watch(filePickerNotifierProvider).value;

                  await ref
                      .read(videoUploadNotifierProvider.notifier)
                      .uploadVideo(file: file!, title: titleController.text);

                  titleController.clear();
                  optionController.clear();

                  ref.invalidate(filePickerNotifierProvider);

                  await ref
                      .refresh(videoRepositoryProvider)
                      .fetchVideos()
                      .then((_) => context.mounted ? context.pop() : null);
                },
                isLoading: ref.watch(videoUploadNotifierProvider).isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
