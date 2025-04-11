import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/models/category/category_model.dart';
import 'package:glaze/data/repository/category/category_repository.dart';
import 'package:glaze/data/repository/file_picker/file_picker_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/profile/provider/recruiter_interests_list_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../core/result_handler/results.dart';
import '../../../gen/assets.gen.dart';
import '../widgets/interest_choice_chip.dart';
import '../widgets/recruiter_header_card.dart';
import '../widgets/recruiter_identification_card.dart';

class ProfileCompletionForm extends HookWidget {
  const ProfileCompletionForm({
    super.key,
    required this.userId,
    required this.role,
  });

  final String userId;
  final String role;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final fullnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final organizationController = useTextEditingController();
    final GoRouter router = GoRouter.of(context);
    final categories = useState<List<CategoryModel>>([]);
    final identification = useState<File?>(null);
    final profileImage = useState<File?>(null);

    return Consumer(
      builder: (context, ref, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (categories.value.isEmpty) {
            categories.value = await ref.watch(categoryRepositoryProvider).fetchCategories();
          }
        });

        final state = ref.watch(getUserProfileNotifierProvider.call(userId));
        final recruiterProfileState = ref.watch(recruiterProfileNotifierProvider.call(userId));
        final intestList = ref.watch(recruiterInterestsNotifierProvider);

        Future<void> handleSubmit() async {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState?.save();

            final result = await ref.read(profileCompletionNotifierProvider.notifier).updateRecruiterProfile(
                  userId: userId,
                  fullName: fullnameController.text,
                  phoneNumber: phoneController.text,
                  organization: organizationController.text,
                  interests: intestList,
                  identificationUrl: identification.value,
                  profileImage: profileImage.value,
                );

            dynamic error;

            if (result is Failure<String, Exception>) {
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
                  title: 'Error Updating Profile',
                  content: error.toString(),
                  onPressed: () {
                    router.pop(context);
                  },
                );
              }
            }

            if (result is Success<String, Exception>) {
              if (context.mounted) {
                router.go(OnboardingRoute(id: userId).location);
              }
            }
          }
        }

        return LoadingLayout(
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
          isLoading: ref.watch(profileCompletionNotifierProvider).isLoading,
          child: state.when(
            data: (data) {
              emailController.text = data?.email ??
                  recruiterProfileState.maybeWhen(
                    orElse: () => '',
                    data: (data) => data?.email ?? emailController.text,
                  );
              phoneController.text = data?.phoneNumber ??
                  recruiterProfileState.maybeWhen(
                    orElse: () => '',
                    data: (data) => data?.phoneNumber ?? phoneController.text,
                  );

              return Padding(
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
                          _UserProfileAvatar(
                            profileImage: profileImage.value,
                            onPressed: () async {
                              profileImage.value = await ref.read(filePickerNotifierProvider.notifier).pickFile(
                                    type: FileType.image,
                                  );
                            },
                          ),
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          InputField.text(
                            controller: fullnameController,
                            inputIcon: SvgPicture.asset(Assets.images.svg.profileIcon.path),
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
                            readOnly: data?.email != null,
                            inputIcon: SvgPicture.asset(Assets.images.svg.emailIcon.path),
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
                            initialValue: data?.phoneNumber ?? '',
                            readOnly: data?.phoneNumber != null,
                            inputIcon: SvgPicture.asset(Assets.images.svg.phoneIcon.path),
                            keyboardType: TextInputType.phone,
                            hintText: 'Phone number',
                            filled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              if (value.length > 15) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          InputField.text(
                            controller: organizationController,
                            inputIcon: SvgPicture.asset(Assets.images.svg.organizationIcon.path),
                            hintText: 'Organization',
                            filled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your organization';
                              }
                              return null;
                            },
                          ),
                          const Gap(16),
                          InterestChoiceChip(
                            categories: categories.value,
                            selectedInterests: intestList,
                            onSelected: (value) {
                              ref.read(recruiterInterestsNotifierProvider.notifier).addToInterestList(value);
                            },
                          ),
                          const Gap(16),
                          if (role == ProfileType.recruiter.name)
                            RecruiterIdentificationCard(
                              recruiterIdentificationImageUrl: recruiterProfileState.maybeWhen(
                                orElse: () => '',
                                data: (data) => data?.identificationUrl ?? '',
                              ),
                              imageFile: identification.value,
                              onTap: () async {
                                identification.value = await ref.read(filePickerNotifierProvider.notifier).pickFile(
                                      type: FileType.image,
                                    );
                              },
                              onClear: () {
                                identification.value = null;
                              },
                            ),
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
              );
            },
            error: (error, stackTrace) {
              return Scaffold(
                body: Center(
                  child: Text(
                    error.toString(),
                  ),
                ),
              );
            },
            loading: () {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
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




    /*
      Future<void> showInterestListModal(BuildContext context, List<CategoryModel> interests) {
        return showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: ColorPallete.inputFilledColor,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => Consumer(
                builder: (context, ref, child) {
                  final selectedInterests = ref.watch(recruiterInterestsNotifierProvider);

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: interests.length,
                    itemBuilder: (context, index) {
                      final interestName = interests[index].name;
                      final isSelected = selectedInterests.contains(interestName);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(interestName),
                        checkColor: ColorPallete.backgroundColor,
                        activeColor: ColorPallete.magenta,
                        selected: isSelected,
                        selectedTileColor: ColorPallete.inputFilledColor,
                        onChanged: (value) {
                          ref.read(recruiterInterestsNotifierProvider.notifier).addToInterestList(interestName);
                          setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      }
    */