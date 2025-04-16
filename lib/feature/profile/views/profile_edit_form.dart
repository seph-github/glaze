import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/feature/camera/provider/content_picker_provider.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/profile/widgets/interest_choice_chip.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/throw_error_exception_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../gen/assets.gen.dart';
import '../provider/profile_interests_list_provider.dart';

class ProfileEditForm extends HookConsumerWidget {
  const ProfileEditForm({
    super.key,
    required this.id,
    // this.data,
  });

  final String id;
  // final Profile? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final imageState = contentPickerNotifierProvider;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final router = GoRouter.of(context);

    final fullnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final organizationController = useTextEditingController();
    final categories = useState<List<CategoryModel>>([]);
    final updatedSelectedInterests = useState<List<String>>([]);
    final currentImage = useState<String?>(null);
    ref.listen(
      imageState,
      (prev, next) {
        if (next.image != null) {
          currentImage.value = next.image?.path;
        }
      },
    );

    ref.listen(
      profileNotifierProvider,
      (prev, next) async {
        if (next.error != null && next.error != prev?.error) {
          throwSupabaseExceptionError(context, next);
        }

        if (next.response.isNotEmpty && next.response != prev?.response) {
          await Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: 'Your Profile Has Been Updated',
            onPressed: () async {
              // Invalidate providers before popping
              ref.invalidate(imageState);
              ref.invalidate(profileInterestsNotifierProvider);

              router.pop();
            },
          )
              .then(
                (_) async => await ref.refresh(profileNotifierProvider.notifier).fetchProfile(id),
              )
              .then(
                (_) async => await Future.delayed(
                  const Duration(milliseconds: 500),
                  () => router.pop(),
                ),
              );
        }
      },
    );

    useEffect(() {
      Future.microtask(() async {
        await ref.read(profileNotifierProvider.notifier).fetchProfile(id);
        await ref.read(profileNotifierProvider.notifier).fetchRecruiterProfile(id);
        categories.value = await ref.read(categoryRepositoryProvider).fetchCategories();
      });
      updatedSelectedInterests.value = state.profile?.interests ?? [];
      fullnameController.text = state.profile?.fullName ?? '';
      emailController.text = state.profile?.email ?? '';
      phoneController.text = state.profile?.phoneNumber ?? '';
      currentImage.value = state.profile?.profileImageUrl;
      organizationController.text = state.recruiterProfile?.organization ?? '';
      return null;
    }, []);

    log('state $state');

    return LoadingLayout(
      isLoading: ref.watch(imageState).isLoading || state.isLoading,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            Assets.images.svg.backArrowIcon.path,
          ),
          style: IconButton.styleFrom(
            backgroundColor: ColorPallete.inputFilledColor,
            shape: const CircleBorder(),
          ),
          onPressed: () {
            formKey.currentState?.reset();
            ref.invalidate(imageState);
            ref.invalidate(profileInterestsNotifierProvider);
            router.pop();
          },
        ),
        title: const Text('Edit Profile'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorPallete.primaryColor,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: currentImage.value != null
                              ? (currentImage.value!.startsWith('http'))
                                  ? NetworkImage(
                                      currentImage.value ?? '',
                                    )
                                  : FileImage(
                                      File(currentImage.value ?? ''),
                                    ) as ImageProvider
                              : AssetImage(
                                  Assets.images.png.profilePlaceholder.path,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text(currentImage.value != null ? 'Change Photo' : 'Pick Photo'),
                      onPressed: () async => await ref.read(imageState.notifier).pickImages(),
                    )
                  ],
                ),
                const Gap(10),
                InputField.text(
                  controller: fullnameController,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.profileIcon.path,
                  ),
                  hintText: 'Full name',
                  filled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const Gap(10),
                InputField.email(
                  controller: emailController,
                  readOnly: state.profile?.email != null,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.emailIcon.path,
                  ),
                  hintText: 'Email address',
                  filled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    } else if (!value.isValidEmail()) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const Gap(10),
                InputField.text(
                  controller: phoneController,
                  readOnly: state.profile?.phoneNumber != null,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.phoneIcon.path,
                  ),
                  hintText: 'Phone number',
                  filled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                if (state.profile?.role == ProfileType.recruiter.name)
                  Column(
                    children: [
                      const Gap(10),
                      InputField.text(
                        controller: organizationController,
                        inputIcon: SvgPicture.asset(
                          Assets.images.svg.organizationIcon.path,
                        ),
                        hintText: 'Organization',
                        filled: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your organization';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const Gap(16),
                InterestChoiceChip(
                  categories: categories.value,
                  selectedInterests: updatedSelectedInterests.value,
                  onSelected: (value) {
                    updatedSelectedInterests.value = ref.read(profileInterestsNotifierProvider.notifier).updateInterestsList(updatedSelectedInterests.value, value);
                  },
                ),
                const Gap(32.0),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    final isProfileImageChanged = currentImage.value != state.profile?.profileImageUrl;

                    await ref.read(profileNotifierProvider.notifier).updateProfile(
                          id: id,
                          email: emailController.text.trim(),
                          fullName: fullnameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          interestList: updatedSelectedInterests.value,
                          profileImage: isProfileImageChanged && currentImage.value != null ? File(currentImage.value!) : null,
                        );
                  },
                ),
                const Gap(32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
