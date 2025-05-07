import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
import 'package:glaze/feature/camera/provider/content_picker_provider.dart';
import 'package:glaze/feature/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/feature/profile/widgets/interest_choice_chip.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/form_validators.dart';
import 'package:glaze/utils/throw_error_exception_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/inputs/phone_number_input.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../gen/assets.gen.dart';
import '../../settings/providers/settings_theme_provider.dart';
import '../provider/profile_interests_list_provider/profile_interests_list_provider.dart';

class ProfileEditForm extends HookConsumerWidget {
  const ProfileEditForm({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    final state = ref.watch(profileNotifierProvider);
    final imageState = contentPickerNotifierProvider;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final router = GoRouter.of(context);
    final isChanged = useState(false);

    final fullnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final organizationController = useTextEditingController();
    final usernameController = useTextEditingController();
    final bioController = useTextEditingController();
    final dialCodeController = useTextEditingController();
    final categories = useState<List<CategoryModel>>([]);
    final updatedSelectedInterests = useState<List<String>>([]);
    final currentImage = useState<String?>(null);
    final user = useState<User?>(null);
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    const ColorFilter colorFilter = ColorFilter.mode(
      ColorPallete.lightBackgroundColor,
      BlendMode.srcIn,
    );

    void checkForChanges() {
      isChanged.value = fullnameController.text.trim() != (state.profile?.fullName ?? '') || emailController.text.trim() != (state.profile?.email ?? '') || phoneController.text.trim() != (state.profile?.phoneNumber ?? '') || usernameController.text.trim() != (state.profile?.username ?? '') || bioController.text.trim() != (state.profile?.bio ?? '') || updatedSelectedInterests.value.toSet().difference((state.profile?.interests ?? []).toSet()).isNotEmpty || currentImage.value != state.profile?.profileImageUrl;
    }

    useEffect(() {
      fullnameController.addListener(checkForChanges);
      emailController.addListener(checkForChanges);
      phoneController.addListener(checkForChanges);
      usernameController.addListener(checkForChanges);
      bioController.addListener(checkForChanges);

      return () {
        fullnameController.removeListener(checkForChanges);
        emailController.removeListener(checkForChanges);
        phoneController.removeListener(checkForChanges);
        usernameController.removeListener(checkForChanges);
        bioController.removeListener(checkForChanges);
      };
    }, []);

    useEffect(() {
      Future.microtask(() async {
        user.value = AuthServices().currentUser;
      });
      return;
    }, []);

    ref.listen(
      imageState,
      (prev, next) {
        if (next.image != null) {
          currentImage.value = next.image?.path;
          checkForChanges();
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
      usernameController.text = state.profile?.username ?? '';
      bioController.text = state.profile?.bio ?? '';

      return null;
    }, []);

    return LoadingLayout(
      isLoading: ref.watch(imageState).isLoading || state.isLoading,
      appBar: AppBarWithBackButton(
        onBackButtonPressed: () {
          formKey.currentState?.reset();
          ref.invalidate(imageState);
          ref.invalidate(profileInterestsNotifierProvider);
          router.pop();
        },
        title: const Text('Edit Profile'),
        centerTitle: true,
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
                                  Assets.images.svg.closeIcon.path,
                                ) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Transform.scale(
                        scale: 0.75,
                        child: currentImage.value != null
                            ? null
                            : SvgPicture.asset(
                                Assets.images.svg.profileIcon.path,
                                fit: BoxFit.contain,
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
                Text(
                  'Edit Personal Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                InputField.text(
                  controller: usernameController,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.profileIcon.path,
                    colorFilter: isLightTheme ? colorFilter : null,
                  ),
                  hintText: 'Username',
                  filled: !isLightTheme,
                  validator: validateUsername,
                ),
                const Gap(10),
                InputField.paragraph(
                  controller: bioController,
                  hintText: 'Describe yourself...',
                  filled: !isLightTheme,
                ),
                const Gap(10),
                InputField.text(
                  controller: fullnameController,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.profileIcon.path,
                    colorFilter: isLightTheme ? colorFilter : null,
                  ),
                  hintText: 'Full name',
                  filled: !isLightTheme,
                  validator: validateFullname,
                ),
                const Gap(10),
                InputField.email(
                  controller: emailController,
                  readOnly: state.profile?.email != null,
                  inputIcon: SvgPicture.asset(
                    Assets.images.svg.emailIcon.path,
                    colorFilter: isLightTheme ? colorFilter : null,
                  ),
                  hintText: 'Email address',
                  filled: !isLightTheme,
                  validator: validateEmail,
                ),
                const Gap(10),
                if (state.profile?.phoneNumber == null)
                  PhoneNumberInput(
                    phoneController: phoneController,
                    dialCodeController: dialCodeController,
                    filled: !isLightTheme,
                    validator: validatePhone,
                  ),
                if (state.profile?.phoneNumber != null)
                  InputField.text(
                    controller: phoneController,
                    readOnly: state.profile?.phoneNumber != null,
                    inputIcon: SvgPicture.asset(
                      Assets.images.svg.phoneIcon.path,
                      colorFilter: isLightTheme ? colorFilter : null,
                    ),
                    hintText: 'Phone number',
                    filled: !isLightTheme,
                    validator: validatePhone,
                  ),
                if ((user.value?.isAnonymous ?? false))
                  Column(
                    children: [
                      const Gap(10),
                      InputField.password(
                        controller: passwordController,
                        inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
                        hintText: 'Password',
                        filled: !isLightTheme,
                        validator: (value) => validatePassword(value),
                      ),
                      const Gap(10),
                      InputField.password(
                        controller: confirmPasswordController,
                        inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
                        hintText: 'Confirm password',
                        filled: !isLightTheme,
                        validator: (value) => validatePassword(value),
                      ),
                    ],
                  ),
                if (state.profile?.role == ProfileType.recruiter.name)
                  Column(
                    children: [
                      const Gap(10),
                      InputField.text(
                        controller: organizationController,
                        inputIcon: SvgPicture.asset(
                          Assets.images.svg.organizationIcon.path,
                          colorFilter: isLightTheme ? colorFilter : null,
                        ),
                        hintText: 'Organization',
                        filled: !isLightTheme,
                        validator: validateOrganization,
                      ),
                    ],
                  ),
                const Gap(16),
                InterestChoiceChip(
                  categories: categories.value,
                  selectedInterests: updatedSelectedInterests.value,
                  onSelected: (value) {
                    updatedSelectedInterests.value = ref.read(profileInterestsNotifierProvider.notifier).updateInterestsList(updatedSelectedInterests.value, value);
                    checkForChanges();
                  },
                ),
                const Gap(32.0),
                PrimaryButton(
                  label: 'Save',
                  onPressed: isChanged.value
                      ? () async {
                          if (formKey.currentState?.validate() ?? false) {
                            formKey.currentState?.save();

                            if (passwordController.text != confirmPasswordController.text) {
                              return showAboutDialog(context: context);
                            }

                            final isProfileImageChanged = currentImage.value != state.profile?.profileImageUrl;

                            if (state.profile?.phoneNumber != null && state.profile!.email!.isNotEmpty) {
                              return await ref.read(profileNotifierProvider.notifier).updateProfile(
                                    id: id,
                                    bio: bioController.text.trim(),
                                    username: usernameController.text.trim(),
                                    fullName: fullnameController.text.trim(),
                                    interestList: updatedSelectedInterests.value,
                                    profileImage: isProfileImageChanged && currentImage.value != null ? File(currentImage.value!) : null,
                                  );
                            }

                            return await ref.read(profileNotifierProvider.notifier).updateProfile(
                                  id: id,
                                  bio: bioController.text.trim(),
                                  username: usernameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phoneNumber: '${dialCodeController.text.trim()}${phoneController.text.trim()}',
                                  interestList: updatedSelectedInterests.value,
                                  profileImage: isProfileImageChanged && currentImage.value != null ? File(currentImage.value!) : null,
                                );
                          }
                        }
                      : null,
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
