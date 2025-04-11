import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/home/provider/video_content_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/drop_downs/custom_drop_down_menu.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/morphism_widget.dart';
import '../../../components/snack_bar/custom_snack_bar.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../data/repository/file_picker/file_picker_provider.dart';

class UploadMomentsCard extends HookWidget {
  const UploadMomentsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final formKey = GlobalKey<FormState>();
    final file = useState<File?>(null);

    final titleController = useTextEditingController();
    final captionController = useTextEditingController();
    final publishAsController = useTextEditingController();
    final categoryController = useTextEditingController();
    final fileController = useTextEditingController();

    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(videoContentNotifierProvider);
        final categoriesState = ref.watch(categoriesNotifierProvider);

        void disposed() {
          titleController.clear();
          captionController.clear();
          categoryController.clear();
          publishAsController.clear();
          fileController.clear();
          ref.invalidate(filePickerNotifierProvider);
          ref.invalidate(videoContentNotifierProvider);
          ref.invalidate(categoriesNotifierProvider);
          formKey.currentState?.reset();
        }

        ref.listen(
          videoContentNotifierProvider,
          (prev, next) {
            if (next.error != null && next.error != prev?.error) {
              final errorMessage = next.error.toString();

              CustomSnackBar.showSnackBar(context, message: errorMessage);
            } else if (next.response.isNotEmpty && next.response != prev?.response) {
              Dialogs.createContentDialog(
                context,
                title: 'Success',
                content: state.response,
                onPressed: () async {
                  () => disposed();
                  router.pop();
                },
              );
            }
          },
        );

        void onPickFile() async {
          file.value = await ref.read(filePickerNotifierProvider.notifier).pickFile(type: FileType.video);

          if (file.value != null) {
            fileController.text = file.value?.path.split('/').last ?? '';
            final int fileSize = file.value?.lengthSync() ?? 0;
            // print('File size ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

            if (fileSize > 100 * 1024 * 1024) {
              // Check if file size exceeds 100MB
              fileController.text = ''; // Clear the controller if invalid

              if (context.mounted) {
                CustomSnackBar.showSnackBar(
                  context,
                  message: 'File size must not exceed 100MB',
                );
              }
            }
            formKey.currentState?.validate(); // Trigger revalidation
          }
        }

        void onSubmit() async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();

            await ref.read(videoContentNotifierProvider.notifier).uploadVideoContent(
                  file: file.value ?? File(''),
                  title: titleController.text,
                  caption: captionController.text,
                  category: categoryController.text,
                );
          }
        }

        return SafeArea(
          child: LoadingLayout(
            isLoading: state.isLoading,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
                color: Colors.white,
                image: const DecorationImage(
                  image: AssetImage('assets/images/png/glaze_card_background_r_32.png'),
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
                      child: Consumer(
                        builder: (context, ref, _) {
                          return MorphismWidget.circle(
                            onTap: () async {
                              if (titleController.text.isNotEmpty || captionController.text.isNotEmpty || categoryController.text.isNotEmpty || publishAsController.text.isNotEmpty || ref.watch(filePickerNotifierProvider).value != null) {
                                await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog.adaptive(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      title: const Text('Discard changes?'),
                                      content: const Text('Are you sure you want to discard your changes?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            () => disposed();
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
                        },
                      ),
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
                    const Gap(10.0),
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
                    const Gap(26.0),
                    Consumer(
                      builder: (context, ref, _) {
                        return CustomDropDownMenu(
                          controller: categoryController,
                          menus: categoriesState.maybeWhen(
                            orElse: () => [],
                            data: (data) {
                              return data.map((e) => e.name).toList();
                            },
                          ),
                          onSelected: (value) {
                            categoryController.text = value ?? '';
                            formKey.currentState?.validate(); // Trigger validation after selection
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
                    const Gap(26.0),
                    FocusButton(
                      controller: fileController,
                      hintText: 'Choose file',
                      onTap: onPickFile,
                      helper: Text(
                        '* max file size 100MB',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ColorPallete.hintTextColor,
                            ),
                      ),
                      validator: (value) {
                        if (file.value == null) {
                          return 'Please choose file';
                        } else {}

                        final fileSize = File(file.value?.path ?? '').lengthSync();
                        if (fileSize > 100 * 1024 * 1024) {
                          // Check if file size exceeds 100MB
                          return 'File size must not exceed 100MB';
                        }

                        return null;
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            file.value?.path.split('/').last ?? '',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Gap(26.0),
                    PrimaryButton(
                      label: 'Upload Moment',
                      onPressed: onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
