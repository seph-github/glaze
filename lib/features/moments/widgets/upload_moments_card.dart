import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/modals/glaze_modals.dart';
import 'package:glaze/features/camera/provider/content_picker_provider.dart';
import 'package:glaze/features/category/provider/category_provider.dart';
import 'package:glaze/features/moments/providers/moments_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:glaze/utils/generate_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../../../components/buttons/focus_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/morphism_widget.dart';
import '../../../components/snack_bar/custom_snack_bar.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class UploadMomentsCard extends HookConsumerWidget {
  const UploadMomentsCard({
    super.key,
    this.showBackground = true,
  });

  final bool showBackground;

  Future<Duration> _getVideoDuration(File file) async {
    final controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();
      return controller.value.duration;
    } finally {
      await controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(contentPickerNotifierProvider);
    final router = GoRouter.of(context);
    final formKey = GlobalKey<FormState>();
    final file = useState<File?>(null);
    final Size(
      :width,
      :height
    ) = MediaQuery.sizeOf(context);

    final thumbnailFuture = useMemoized(
      () async {
        final videoFile = File(fileState.video?.path ?? '');
        final duration = await _getVideoDuration(videoFile);

        if (duration.inSeconds > 15 && context.mounted) {
          await Dialogs.createContentDialog(
            context,
            title: 'Error',
            content: 'Your video exceeds the maximum allowed duration. Please subscribe or purchase a plan to upload longer videos.',
            onPressed: () => context.pop(),
          );
          throw Exception('Video too long! Max 15 seconds allowed.');
        } else {
          return await getVideoThumbnail(File(fileState.video?.path ?? ''));
        }
      },
      [
        fileState.video
      ],
    );

    final titleController = useTextEditingController();
    final captionController = useTextEditingController();
    final categoryController = useTextEditingController();
    final fileController = useTextEditingController();

    final state = ref.watch(momentsNotifierProvider);
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
      momentsNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(
            context,
            content: Text(errorMessage),
          );
        }

        if (next.response != null && prev?.response != next.response) {
          Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: next.response ?? '',
            onPressed: () async {
              titleController.clear();
              captionController.clear();
              categoryController.clear();
              fileController.clear();
              file.value = null;
              ref.invalidate(contentPickerNotifierProvider);

              return router.pop();
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
          },
        );
      }

      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        final thumbnail = await thumbnailFuture;
        await ref.read(momentsNotifierProvider.notifier).uploadVideoContent(
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
        child: Stack(
          children: [
            if (showBackground)
              Positioned(
                top: -150,
                left: 0,
                right: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 100,
                    sigmaY: 100,
                  ),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorPallete.magenta.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          blurStyle: BlurStyle.solid,
                          color: ColorPallete.magenta.withValues(alpha: 0.4),
                          blurRadius: 150,
                          spreadRadius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: height,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBackground)
                    Column(
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
                        const Divider(
                          indent: 12.0,
                          endIndent: 12.0,
                        ),
                      ],
                    ),
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
                              ],
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
                            InputField(
                              hintText: 'Category',
                              controller: categoryController,
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
                            if (fileState.video != null) _buildContentThumbnailPreview(thumbnailFuture, ref),
                            const Gap(30.0),
                            FocusButton(
                              controller: fileController,
                              borderRadius: 16.0,
                              validator: (value) {
                                if (file.value == null) {
                                  return 'Please choose file';
                                }

                                final fileSize = File(file.value?.path ?? '').lengthSync();

                                if (fileSize > 100 * 1024 * 1024) {
                                  return 'File size must not exceed 100MB';
                                }
                                return null;
                              },
                              onTap: () async => await onImageSource(context, ref),
                              child: Center(
                                child: Text(
                                  'Choose a Moment',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            const Gap(30.0),
                            PrimaryButton(
                              label: 'Upload Moment',
                              onPressed: onSubmit,
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
          ],
        ),
      ),
    );
  }

  Widget _buildContentThumbnailPreview(Future<File> thumbnailFuture, WidgetRef ref) {
    return Column(
      children: [
        const Gap(26.0),
        FutureBuilder<File>(
          future: thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        image: DecorationImage(
                          image: FileImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
              );
            } else {
              return const Text('No thumbnail available');
            }
          },
        ),
      ],
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
          child: Text(
            'Gallery',
            style: Theme.of(ctx).textTheme.titleLarge,
          ),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            await ref.read(contentPickerNotifierProvider.notifier).takeVideo(
                  preferedCameraDevice: CameraDevice.rear,
                );

            if (ctx.mounted) {
              ctx.pop();
            }
          },
          child: Text(
            'Camera',
            style: Theme.of(ctx).textTheme.titleLarge,
          ),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            ctx.pop();
          },
          child: Text(
            'Cancel',
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                ),
          ),
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
