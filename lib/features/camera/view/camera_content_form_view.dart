import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/modals/glaze_modals.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/features/camera/provider/camera_upload_content_provider/camera_upload_content_provider.dart';
import 'package:glaze/features/camera/provider/content_picker_provider/content_picker_provider.dart';
import 'package:glaze/features/category/provider/category_provider.dart';
import 'package:glaze/features/moments/providers/upload_moments_form_provider/upload_moments_form_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';

import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/snack_bar/custom_snack_bar.dart';
import '../../../core/styles/color_pallete.dart';

const googleApiKey = String.fromEnvironment('googleApiKey', defaultValue: '');

class CameraContentFormView extends HookConsumerWidget {
  const CameraContentFormView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraUploadContentNotifierProvider);
    final categoryState = ref.watch(categoryNotifierProvider);

    final formNotifier = ref.read(uploadMomentFormProvider.notifier);
    final formKey = GlobalKey<FormState>();

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
      cameraUploadContentNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(
            context,
            content: Text(errorMessage),
          );
        }

        if (next.responseMessage != null && prev?.responseMessage != next.responseMessage) {
          Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: next.responseMessage ?? '',
            onPressed: () {
              formNotifier.clearForm();
              ref.invalidate(contentPickerNotifierProvider);

              const HomeRoute().go(context);
            },
          );
        }
      },
    );

    ref.listen(
      contentPickerNotifierProvider,
      (prev, next) {
        if (next.video != null) {
          ref.read(uploadMomentFormProvider.notifier).setFile(File(next.video!.path));
        }
      },
    );

    void onSubmit() async {
      if (formNotifier.file == null) {
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

        await ref.read(cameraUploadContentNotifierProvider.notifier).uploadVideoContent();
      }
    }

    return LoadingLayout(
      isLoading: state.isLoading || categoryState.isLoading,
      appBar: const AppBarWithBackButton(),
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: <Widget>[
              const Gap(16.0),
              Column(
                children: [
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
                controller: formNotifier.titleController,
                onChanged: (_) => formNotifier.syncControllersToState(),
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
                controller: formNotifier.captionController,
                onChanged: (_) => formNotifier.syncControllersToState(),
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
                controller: formNotifier.locationController,
                readOnly: true,
                hintText: 'Location',
                onTap: () async {
                  return await GlazeModal.showCustomModalPopup(
                    context,
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () async {
                              context.pop();

                              await Future.delayed(
                                const Duration(milliseconds: 200),
                                () async {
                                  if (context.mounted) {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  }
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            child: const Text('Done'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GooglePlacesAutoCompleteTextFormField(
                            autofocus: true,
                            googleAPIKey: googleApiKey,
                            textEditingController: formNotifier.locationController,
                            onPlaceDetailsWithCoordinatesReceived: (prediction) {
                              formNotifier.latitudeController.text = prediction.lat as String;
                              formNotifier.longitudeController.text = prediction.lng as String;
                              formNotifier.syncControllersToState();
                            },
                            onSuggestionClicked: (prediction) {
                              formNotifier.locationController.text = prediction.description as String;
                              formNotifier.locationController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                            },
                            onChanged: (_) => formNotifier.syncControllersToState(),
                            onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Gap(26.0),
              InputField.text(
                controller: formNotifier.tagsController,
                onChanged: (_) {
                  formNotifier.setTags();
                },
                hintText: 'Add tags',
                helper: Text(
                  'Separate it with a comma',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ColorPallete.hintTextColor,
                      ),
                ),
              ),
              const Gap(16.0),
              InputField(
                hintText: 'Category',
                controller: formNotifier.categoryController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please add a category';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () async {
                  await GlazeModal.showCategoryModalPopup(context, categoryState, formNotifier.categoryController);
                  formNotifier.syncControllersToState();
                },
              ),
              const Gap(60.0),
              PrimaryButton(
                label: 'Upload Moment',
                borderRadius: 16.0,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
