import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/drop_downs/custom_drop_down_menu.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/morphism_widget.dart';
import '../../../core/result_handler/results.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../data/repository/file_picker/file_picker_provider.dart';
import '../../../data/repository/video_repository/video_repository.dart';

class UploadMomentsCard extends StatelessWidget {
  const UploadMomentsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final formKey = GlobalKey<FormState>();

    final TextEditingController titleController = TextEditingController();
    final TextEditingController captionController = TextEditingController();
    final TextEditingController publishAsController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController fileController = TextEditingController();

    void onPickFile(WidgetRef ref) async {
      await ref
          .read(filePickerNotifierProvider.notifier)
          .pickFile(type: FileType.video);
      final pickedFile = ref.watch(filePickerNotifierProvider).maybeWhen(
            orElse: () => null,
            data: (data) => data,
          );
      if (pickedFile != null) {
        fileController.text = pickedFile.path.split('/').last;
        final fileSize = pickedFile.lengthSync();
        // print('File size ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        if (fileSize > 100 * 1024 * 1024) {
          // Check if file size exceeds 100MB
          fileController.text = ''; // Clear the controller if invalid

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must not exceed 100MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        formKey.currentState?.validate(); // Trigger revalidation
      }
    }

    void onSubmit(WidgetRef ref) async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        final Result<void, Exception> result =
            await ref.read(videoUploadNotifierProvider.notifier).uploadVideo(
                  file: ref.watch(filePickerNotifierProvider).value!,
                  title: titleController.text,
                  caption: captionController.text,
                  category: categoryController.text,
                );

        dynamic error;

        if (result is Failure<void, Exception>) {
          switch (result.error) {
            case StorageException _:
              error = result.error as StorageException;
              break;
            case PostgrestException _:
              error = result.error as PostgrestException;
              break;
          }

          if (context.mounted) {
            await Dialogs.createContentDialog(
              context,
              title: 'Error',
              content: error.message.toString(),
              onPressed: () {
                router.pop();
              },
            );
          }
        }

        if (result is Success<void, Exception>) {
          titleController.clear();
          captionController.clear();
          categoryController.clear();
          fileController.clear();
          ref.invalidate(filePickerNotifierProvider);

          formKey.currentState?.reset();

          if (context.mounted) {
            await Dialogs.createContentDialog(
              context,
              title: 'Success',
              content: 'Video uploaded successfully',
              onPressed: () {
                router.pop();
              },
            );
          }
        }
      }
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
          color: Colors.white,
          image: const DecorationImage(
            image:
                AssetImage('assets/images/png/glaze_card_background_r_32.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Consumer(builder: (context, ref, _) {
                  return MorphismWidget.circle(
                    onTap: () async {
                      if (titleController.text.isNotEmpty ||
                          captionController.text.isNotEmpty ||
                          categoryController.text.isNotEmpty ||
                          publishAsController.text.isNotEmpty ||
                          ref.watch(filePickerNotifierProvider).value != null) {
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog.adaptive(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              title: const Text('Discard changes?'),
                              content: const Text(
                                  'Are you sure you want to discard your changes?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    titleController.clear();
                                    captionController.clear();
                                    categoryController.clear();
                                    publishAsController.clear();
                                    ref.invalidate(filePickerNotifierProvider);
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  },
                                  child: const Text('Discard'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        router.pop();
                      }
                    },
                    size: 28.0,
                    child: SvgPicture.asset('assets/images/svg/Close Icon.svg'),
                  );
                }),
              ),
              MorphismWidget.circle(
                size: 64.0,
                child: SvgPicture.asset('assets/images/svg/Upload Icon.svg'),
              ),
              Text(
                'Upload Your Moment',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                'Share your talent with the community!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: ColorPallete.hintTextColor,
                    ),
              ),
              const Gap(16.0),
              InputField.text(
                controller: titleController,
                hintText: 'Enter video title',
                helper: Text(
                  '* up to 50 characters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ColorPallete.hintTextColor,
                      ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter video title';
                  }
                  return null;
                },
              ),
              InputField.paragraph(
                controller: captionController,
                maxLines: 5,
                hintText: 'Write video caption',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter video caption';
                  }
                  return null;
                },
              ),
              const Gap(16.0),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(categoriesNotifierProvider);
                  return CustomDropDownMenu(
                    controller: categoryController,
                    menus: state.maybeWhen(
                      orElse: () => [],
                      data: (data) {
                        return data.map((e) => e.name).toList();
                      },
                    ),
                    onSelected: (value) {
                      categoryController.text = value ?? '';
                      formKey.currentState
                          ?.validate(); // Trigger validation after selection
                    },
                    hintText: 'Category',
                    validator: (value) {
                      if (categoryController.text.isEmpty) {
                        // Validate the controller's text
                        return 'Please select category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const Gap(16.0),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(filePickerNotifierProvider);

                  return FocusButton(
                    controller: fileController,
                    hintText: 'Choose file',
                    onTap: () => onPickFile(ref),
                    helper: Text(
                      '* max file size 100MB',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: ColorPallete.hintTextColor,
                          ),
                    ),
                    onChanged: (value) {
                      final fileName = state.maybeWhen(
                        orElse: () => value,
                        data: (data) => data?.path.split('/').last ?? '',
                      );

                      fileController.text = fileName;
                      if (fileName.isNotEmpty) {
                        formKey.currentState?.validate();
                      }
                    },
                    validator: (value) {
                      final pickedFile =
                          ref.watch(filePickerNotifierProvider).maybeWhen(
                                orElse: () => null,
                                data: (data) => data,
                              );

                      if (pickedFile == null) {
                        return 'Please choose file';
                      } else {}

                      final fileSize = File(pickedFile.path).lengthSync();
                      if (fileSize > 100 * 1024 * 1024) {
                        // Check if file size exceeds 100MB
                        return 'File size must not exceed 100MB';
                      }

                      return null;
                    },
                    child: state.maybeWhen(
                      orElse: () => null,
                      data: (data) {
                        if (data == null) return null;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.path.split('/').last,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              const Gap(16.0),
              Consumer(
                builder: (context, ref, _) {
                  return PrimaryButton(
                    isLoading: ref.watch(videoUploadNotifierProvider).isLoading,
                    label: 'Upload Moment',
                    onPressed: () => onSubmit(ref),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
