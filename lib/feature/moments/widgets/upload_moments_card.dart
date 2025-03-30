import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/drop_downs/custom_drop_down_menu.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/morphism_widget.dart';
import '../../../core/styles/color_pallete.dart';
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

    void onPickFile(WidgetRef ref) async {
      ref.read(filePickerNotifierProvider.notifier).pickFile();
    }

    void onSubmit(WidgetRef ref) async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        ref.read(videoUploadNotifierProvider.notifier).uploadVideo(
              file: ref.watch(filePickerNotifierProvider).value!,
              title: titleController.text,
              caption: captionController.text,
              category: categoryController.text,
              publishAs: publishAsController.text,
            );
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
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please enter video title';
                  }
                  return null;
                },
              ),
              InputField.paragraph(
                controller: captionController,
                maxLines: 5,
                hintText: 'Write video caption',
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please enter video caption';
                  }
                  return null;
                },
              ),
              const Gap(16.0),
              CustomDropDownMenu(
                menus: const [],
                onSelected: (value) {
                  publishAsController.text = value as String;
                },
                hintText: 'Publish as',
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please select publish as';
                  }
                  return null;
                },
              ),
              const Gap(16.0),
              CustomDropDownMenu(
                menus: const [],
                onSelected: (value) {
                  categoryController.text = value as String;
                },
                hintText: 'Category',
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              const Gap(16.0),
              Consumer(builder: (context, ref, _) {
                return FocusButton(
                  hintText: 'Choose File',
                  isLoading: ref.watch(filePickerNotifierProvider).isLoading,
                  onTap: () => onPickFile(ref),
                  helper: Text(
                    '* max file size 100MB',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ColorPallete.hintTextColor,
                        ),
                  ),
                  validator: (p0) {
                    if (p0!.isEmpty) {
                      return 'Please choose file';
                    }
                    return null;
                  },
                );
              }),
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
