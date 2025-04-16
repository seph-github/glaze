import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/models/category/category_model.dart';
import 'package:glaze/data/repository/category/category_repository.dart';
import 'package:glaze/feature/camera/provider/content_picker_provider.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/profile/provider/profile_interests_list_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/snack_bar/custom_snack_bar.dart';
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

    final formKey = GlobalKey<FormState>();
    final router = GoRouter.of(context);

    final fullnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final organizationController = useTextEditingController();

    final categories = useState<List<CategoryModel>>([]);
    final identification = useState<File?>(null);
    final profileImage = useState<File?>(null);
    final interestList = ref.watch(profileInterestsNotifierProvider);

    ref.listen(
      contentPickerNotifierProvider,
      (prev, next) {
        if (next.image != null) {
          profileImage.value = File(next.image!.path);
        }

        if (next.identification != null) {
          identification.value = File(next.identification!.path);
        }
      },
    );

    ref.listen(
      profileNotifierProvider,
      (prev, next) async {
        if (next.profile != null && next.profile != prev?.profile) {
          fullnameController.text = next.profile?.fullName ?? '';
          emailController.text = next.profile?.email ?? '';
          phoneController.text = next.profile?.phoneNumber ?? '';
        }

        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(context, message: errorMessage);
        }

        if (next.response.isNotEmpty && next.response != prev?.response) {
          await Dialogs.createContentDialog(
            context,
            title: 'Success',
            content: next.response,
            onPressed: () async {
              ref.invalidate(profileInterestsNotifierProvider);

              fullnameController.dispose();
              emailController.dispose();
              phoneController.dispose();
              organizationController.dispose();
              categories.dispose();
              identification.dispose();
              profileImage.dispose();
              await router.push(OnboardingRoute(id: userId).location);
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

        await ref.read(profileNotifierProvider.notifier).updateProfile(
              id: userId,
              email: emailController.text,
              fullName: fullnameController.text,
              phoneNumber: phoneController.text,
              interestList: interestList,
              organization: organizationController.text,
              profileImage: profileImage.value,
              identification: identification.value,
              role: ProfileType.values.byName(role),
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
                  _UserProfileAvatar(
                    profileImage: profileImage.value,
                    onPressed: () async {
                      await ref.read(contentPickerNotifierProvider.notifier).pickImages();
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
                    readOnly: state.profile?.fullName != null,
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
                    readOnly: state.profile?.email != null,
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
                    readOnly: state.profile?.phoneNumber != null,
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
                  if (role == ProfileType.recruiter.name)
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
                    selectedInterests: interestList,
                    onSelected: (value) => ref.read(profileInterestsNotifierProvider.notifier).addToInterestList(value),
                  ),
                  const Gap(16),
                  if (role == ProfileType.recruiter.name)
                    RecruiterIdentificationCard(
                      imageFile: identification.value,
                      onTap: () async => await ref.read(contentPickerNotifierProvider.notifier).pickIdentificationImage(),
                      onClear: () => identification.value = null,
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