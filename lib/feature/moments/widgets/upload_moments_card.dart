import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/modals/glaze_modals.dart';
import 'package:glaze/feature/camera/provider/content_picker_provider.dart';
import 'package:glaze/feature/category/provider/category_provider.dart';
import 'package:glaze/feature/home/provider/video_content_provider/video_content_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/generate_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/morphism_widget.dart';
import '../../../components/snack_bar/custom_snack_bar.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../settings/providers/settings_theme_provider.dart';

class UploadMomentsCard extends HookConsumerWidget {
  const UploadMomentsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    final fileState = ref.watch(contentPickerNotifierProvider);
    final router = GoRouter.of(context);
    final formKey = GlobalKey<FormState>();
    final file = useState<File?>(null);
    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);
    final thumbnailFuture = useMemoized(() => getVideoThumbnail(File(fileState.video?.path ?? '')), [
      fileState.video
    ]);

    final titleController = useTextEditingController();
    final captionController = useTextEditingController();
    final categoryController = useTextEditingController();
    final fileController = useTextEditingController();

    final state = ref.watch(videoContentNotifierProvider);
    final categoryState = ref.watch(categoryNotifierProvider);

    useEffect(
      () {
        Future.microtask(() async {
          await ref.read(categoryNotifierProvider.notifier).fetchCategories();
        });
        return;
      },
      [],
    );

    ref.listen(
      videoContentNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(context, message: errorMessage);
        } else if (next.response != null && next.response != prev?.response) {
          Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: state.response ?? '',
            onPressed: () async {
              titleController.clear();
              captionController.clear();
              categoryController.clear();
              fileController.clear();
              file.value = null;
              ref.invalidate(contentPickerNotifierProvider);

              router.pop();
            },
          );
        }
      },
    );

    ref.listen(
      contentPickerNotifierProvider,
      (prev, next) {
        if (next.video != null) {
          file.value = File(next.video!.path);
          fileController.text = file.value?.path.split('/').last ?? '';
        }
      },
    );

    void onCancelUploadMoment() async {
      if (titleController.text.isNotEmpty || captionController.text.isNotEmpty || categoryController.text.isNotEmpty || fileController.text.isNotEmpty || file.value != null) {
        await showUploadMomentCard(context);
      } else {
        context.pop();
      }
    }

    void onSubmit() async {
      if (file.value == null) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                title: const Text('Error'),
                content: const Center(
                  child: Text('The moment is empty please choose a video from gallery or camera.'),
                ),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
      }

      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        final thumbnail = await thumbnailFuture;
        await ref.read(videoContentNotifierProvider.notifier).uploadVideoContent(
              file: file.value ?? File(''),
              thumbnail: thumbnail,
              title: titleController.text,
              caption: captionController.text,
              category: categoryController.text,
            );
      }
    }

    return RepaintBoundary(
      child: LoadingLayout(
        isLoading: state.isLoading || categoryState.isLoading,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage(Assets.images.png.glazeCardBackgroundR32.path),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: MorphismWidget.circle(
                    onTap: onCancelUploadMoment,
                    size: 28.0,
                    child: SvgPicture.asset(Assets.images.svg.closeIcon.path),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView(
                      children: <Widget>[
                        const Gap(16.0),
                        Column(
                          children: [
                            MorphismWidget.circle(
                              size: 64.0,
                              child: SvgPicture.asset(Assets.images.svg.uploadIcon.path),
                            ),
                          ],
                        ),
                        Text(
                          'Upload Your Moment',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
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
                          lightModeColor: isLightTheme ? Colors.white : null,
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
                          lightModeColor: isLightTheme ? Colors.white : null,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter video caption';
                            }
                            return null;
                          },
                        ),
                        const Gap(26.0),
                        InputField(
                          hintText: 'Category',
                          controller: categoryController,
                          lightModeColor: isLightTheme ? Colors.white : null,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please add a category';
                            }
                            return null;
                          },
                          readOnly: true,
                          onTap: () async {
                            await GlazeModal.showCategoryModalPopup(context, categoryState, categoryController);
                          },
                        ),
                        if (fileState.video != null)
                          Column(
                            children: [
                              const Gap(26.0),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  FutureBuilder<File>(
                                    future: thumbnailFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator
                                      } else if (snapshot.hasData) {
                                        return AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white, // Border color
                                                width: 0.5, // Border width
                                              ),
                                              borderRadius: BorderRadius.circular(16.0), // Rounded corners
                                              image: DecorationImage(
                                                image: FileImage(snapshot.data!), // Use the thumbnail as a background
                                                fit: BoxFit.cover, // Adjust the image to cover the container
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Text('No thumbnail available'); // Fallback message
                                      }
                                    },
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton.filled(
                                      onPressed: () => ref.invalidate(contentPickerNotifierProvider),
                                      visualDensity: const VisualDensity(horizontal: -3, vertical: -2),
                                      focusColor: ColorPallete.primaryColor,
                                      color: ColorPallete.primaryColor,
                                      icon: SvgPicture.asset(Assets.images.svg.closeIcon.path),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const Gap(26.0),
                        FocusButton(
                          controller: fileController,
                          borderRadius: 16.0,
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
                          onTap: () async => await onImageSource(context, ref),
                          child: Center(
                            child: Text(
                              'Choose a Moment',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ColorPallete.whiteSmoke,
                                  ),
                            ),
                          ),
                        ),
                        const Gap(26.0),
                        PrimaryButton(
                          label: 'Upload Moment',
                          onPressed: onSubmit,
                          // onPressed: () {},
                        ),
                        const Gap(26.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> onImageSource(BuildContext ctx, WidgetRef ref) async {
  return await showCupertinoModalPopup(
    context: ctx,
    builder: (ctx) => CupertinoActionSheet(
      title: Text('Upload Your Moments', style: Theme.of(ctx).textTheme.headlineSmall),
      message: const Text('Please choose from the options below.'),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            await ref.read(contentPickerNotifierProvider.notifier).pickVideos();

            if (ctx.mounted) {
              ctx.pop();
            }
          },
          child: const Text('Gallery'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            await ref.read(contentPickerNotifierProvider.notifier).takeVideo(
                  prefferedCameraDevice: CameraDevice.rear,
                );

            if (ctx.mounted) {
              ctx.pop();
            }
          },
          child: const Text('Camera'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            ctx.pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

Future<void> showUploadMomentCard(BuildContext context) async {
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
              () {};
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
}
