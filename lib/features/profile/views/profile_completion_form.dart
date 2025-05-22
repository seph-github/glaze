import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/components/inputs/phone_number_input.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/models/category/category_model.dart';
import 'package:glaze/data/repository/category/category_repository.dart';
import 'package:glaze/features/camera/provider/content_picker_provider/content_picker_provider.dart';
import 'package:glaze/features/profile/provider/profile_form_provider/profile_form_provider.dart';
import 'package:glaze/features/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/features/profile/provider/profile_interests_list_provider/profile_interests_list_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:glaze/utils/form_validators.dart';
import 'package:glaze/utils/throw_error_exception_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../gen/assets.gen.dart';
import '../../auth/services/auth_services.dart';
import '../widgets/interest_choice_chip.dart';
import '../widgets/recruiter_header_card.dart';
import '../widgets/recruiter_identification_card.dart';

class ProfileCompletionForm extends HookConsumerWidget {
  const ProfileCompletionForm({
    super.key,
    required this.userId,
    required this.role,
  });

  final String userId;
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final formNotifier = ref.watch(profileFormNotifierProvider.notifier);
    final formKey = GlobalKey<FormState>();
    final router = GoRouter.of(context);
    final categories = useState<List<CategoryModel>>([]);

    ref.listen(
      contentPickerNotifierProvider,
      (prev, next) {
        if (next.image != null) {
          formNotifier.setProfileImage(File(next.image!.path));
        }

        if (next.identification != null) {
          formNotifier.setIdentificationFile(File(next.identification!.path));
        }
      },
    );

    ref.listen(
      profileNotifierProvider,
      (prev, next) async {
        if (next.error != null && next.error != prev?.error) {
          throwAuthExceptionError(context, next, useDialog: true);
        }

        if (next.response != null && next.response != prev?.response) {
          await Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: next.response as String,
            onPressed: () async {
              ref.invalidate(profileInterestsListNotifierProvider);
              formNotifier.clearForm();
              router.go(const HomeRoute().location);
            },
          );
        }
      },
    );

    useEffect(
      () {
        Future.microtask(
          () async {
            final User? user = AuthServices().currentUser;
            await ref.read(profileNotifierProvider.notifier).fetchProfile(user!.id);

            categories.value = await ref.watch(categoryRepositoryProvider).fetchCategories();
          },
        );

        return;
      },
      [],
    );

    Future<void> handleSubmit() async {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        final state = ref.watch(profileFormNotifierProvider);

        await ref.read(profileNotifierProvider.notifier).updateProfile(
              id: userId,
              email: state.email,
              fullName: state.fullname,
              countryCode: state.code,
              phoneNumber: state.phone,
              interestList: state.interestList,
              organization: state.organization,
              profileImage: state.profileImage,
              identification: state.identificationImage,
            );
      }
    }

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: AppBar(
        title: Text(
          '${role == ProfileType.recruiter.name ? 'Create Recruiter' : 'Complete Your'} Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (role == ProfileType.recruiter.name) const RecruiterHeaderCard(),
                  const Gap(16),
                  if (role == ProfileType.recruiter.name)
                    Text(
                      'Fill out the form below to become a verified recruiter. We’ll review your application within 24 hours.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ColorPallete.hintTextColor,
                          ),
                    ),
                  Consumer(builder: (context, ref, _) {
                    return _UserProfileAvatar(
                      profileImage: ref.watch(profileFormNotifierProvider).profileImage,
                      onPressed: () async {
                        await ref.read(contentPickerNotifierProvider.notifier).pickImages();
                      },
                    );
                  }),
                  Text(
                    'Personal Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  InputField.text(
                    controller: formNotifier.fullnameController,
                    onChanged: (_) => formNotifier.syncControllerToState(),
                    readOnly: state.profile?.fullName != null,
                    inputIcon: SvgPicture.asset(Assets.images.svg.profileIcon.path),
                    hintText: 'Full name',
                    filled: true,
                    validator: validateFullname,
                  ),
                  const Gap(10),
                  InputField.email(
                    controller: formNotifier.emailController,
                    onChanged: (_) => formNotifier.syncControllerToState(),
                    readOnly: state.profile?.email != null,
                    inputIcon: SvgPicture.asset(Assets.images.svg.emailIcon.path),
                    hintText: 'Email address',
                    filled: true,
                    validator: validateEmail,
                  ),
                  const Gap(10),
                  PhoneNumberInput(
                    dialCodeController: formNotifier.codeController,
                    phoneController: formNotifier.phoneController,
                    onChanged: (_) => formNotifier.syncControllerToState(),
                    onCodeChanged: (_) => formNotifier.syncControllerToState(),
                    filled: true,
                    validator: validatePhone,
                  ),
                  const Gap(10),
                  if (role == ProfileType.recruiter.name)
                    InputField.text(
                      controller: formNotifier.organizationController,
                      onChanged: (_) => formNotifier.syncControllerToState(),
                      inputIcon: SvgPicture.asset(Assets.images.svg.organizationIcon.path),
                      hintText: 'Organization',
                      filled: true,
                      validator: validateOrganization,
                    ),
                  const Gap(16),
                  Consumer(builder: (context, ref, _) {
                    return InterestChoiceChip(
                      categories: categories.value,
                      selectedInterests: ref.watch(profileFormNotifierProvider).interestList,
                      onSelected: (value) {
                        ref.read(profileInterestsListNotifierProvider.notifier).addToInterestList(value);
                        final interests = ref.watch(profileInterestsListNotifierProvider);

                        formNotifier.interestList = interests;

                        formNotifier.syncControllerToState();
                      },
                    );
                  }),
                  const Gap(16),
                  if (role == ProfileType.recruiter.name)
                    Consumer(builder: (context, ref, _) {
                      return RecruiterIdentificationCard(
                        imageFile: ref.watch(profileFormNotifierProvider).identificationImage,
                        onTap: () async => await ref.read(contentPickerNotifierProvider.notifier).pickIdentificationImage(),
                        onClear: () => formNotifier.clearIdenticationImage(),
                      );
                    }),
                  PrimaryButton(
                    label: role == ProfileType.recruiter.name ? 'Submit Verification' : 'Save',
                    onPressed: handleSubmit,
                  ),
                  const Gap(32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar({
    required this.profileImage,
    this.onPressed,
  });

  final File? profileImage;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                height: 125,
                width: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorPallete.primaryColor,
                    width: 2,
                  ),
                  image: profileImage != null
                      ? DecorationImage(
                          image: FileImage(profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage == null
                    ? Transform.scale(
                        scale: 0.75,
                        child: SvgPicture.asset(
                          Assets.images.svg.profileIcon.path,
                          height: 10,
                        ),
                      )
                    : null,
              ),
              const Gap(8.0),
              InkWell(
                onTap: onPressed,
                child: Text(
                  profileImage != null ? 'Change Photo' : 'Add Photo',
                ),
              ),
              const Gap(8.0),
            ],
          ),
        );
      },
    );
  }
}
