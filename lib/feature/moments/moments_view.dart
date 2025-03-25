import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:glaze/components/buttons/focus_button.dart';
import 'package:glaze/components/inputs/input_field.dart';
import 'package:go_router/go_router.dart';

import '../../components/buttons/primary_button.dart';
import '../../components/drop_downs/custom_drop_down_menu.dart';
import '../../data/repository/file_picker/file_picker_provider.dart';
import '../../data/repository/video_repository/video_repository.dart';

class MomentsView extends ConsumerWidget {
  const MomentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    final titleController = TextEditingController();
    final captionController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 32.0,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GlassContainer.clearGlass(
                height: height * 0.65,
                width: double.infinity,
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16.0),
                borderColor: Colors.transparent,
                child: Column(
                  children: [
                    const Text(
                      'Upload Your Moment',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Share your talent with the community!',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white54,
                          fontWeight: FontWeight.w400),
                    ),
                    InputField.text(
                      controller: titleController,
                      hintText: 'Video Title',
                      borderRadius: 32.0,
                      helper: const Text('* 50 characters'),
                    ),
                    InputField.paragraph(
                      controller: captionController,
                      borderRadius: 32.0,
                      hintText: 'Write a caption',
                    ),
                    CustomDropDownMenu(
                      hintText: 'Publish As',
                      menus: const [],
                      onSelected: (value) {},
                    ),
                    CustomDropDownMenu(
                      hintText: 'Select Category',
                      menus: const [],
                      onSelected: (value) {},
                    ),
                    const FocusButton(
                      helper: Text('* Maximum file size 100mb'),
                      borderRadius: 32.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Choose a File'),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      label: 'Upload Moment',
                      borderRadius: 32.0,
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        final file =
                            ref.watch(filePickerNotifierProvider).value;

                        await ref
                            .read(videoUploadNotifierProvider.notifier)
                            .uploadVideo(
                                file: file!, title: titleController.text);

                        titleController.clear();
                        captionController.clear();

                        ref.invalidate(filePickerNotifierProvider);

                        await ref
                            .refresh(videoRepositoryProvider)
                            .fetchVideos()
                            .then((_) => context.mounted ? router.pop() : null);
                      },
                      isLoading:
                          ref.watch(videoUploadNotifierProvider).isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
