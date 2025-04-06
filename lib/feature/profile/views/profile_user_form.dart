import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/data/repository/file_picker/file_picker_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/focus_button.dart';
import '../../../components/inputs/input_field.dart';
import '../../../components/modals/glaze_modals.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../gen/assets.gen.dart';
import '../provider/recruiter_interests_list_provider.dart';

class ProfileUserForm extends HookWidget {
  const ProfileUserForm({
    super.key,
    required this.id,
  });

  final String id;
  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final router = GoRouter.of(context);
    final imageUrl = useState<String?>(null);
    File? file;

    TextEditingController? fullnameController = TextEditingController();
    TextEditingController? emailController = TextEditingController();
    TextEditingController? phoneController = TextEditingController();
    TextEditingController? organizationController = TextEditingController();
    TextEditingController? interestController = TextEditingController();

    return Consumer(
      builder: (context, ref, _) {
        file = ref.watch(filePickerNotifierProvider).value;
        return LoadingLayout(
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
                ref.invalidate(filePickerNotifierProvider);
                ref.invalidate(recruiterInterestsNotifierProvider);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              image: imageUrl.value != null
                                  ? NetworkImage(
                                      imageUrl.value ?? '',
                                    )
                                  : FileImage(
                                      file ?? File(''),
                                    ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: imageUrl.value == null && file == null
                              ? Transform.scale(
                                  scale: 0.75,
                                  child: SvgPicture.asset(
                                    Assets.images.svg.profileIcon.path,
                                    height: 10,
                                  ),
                                )
                              : null,
                        ),
                        TextButton(
                          child: Text(
                              ref.watch(filePickerNotifierProvider).value !=
                                      null
                                  ? 'Change Photo'
                                  : 'Pick Photo'),
                          onPressed: () => ref
                              .read(filePickerNotifierProvider.notifier)
                              .pickFile(type: FileType.image),
                        )
                      ],
                    ),
                    const Gap(10),
                    InputField.text(
                      controller: fullnameController,
                      inputIcon: SvgPicture.asset(
                        'assets/images/svg/profile.svg',
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
                      // readOnly: data?.email != null,
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
                      // initialValue: data?.phoneNumber ?? '',
                      // readOnly: data?.phoneNumber != null,
                      inputIcon: SvgPicture.asset(
                        // 'assets/images/svg/phone_icon.svg',
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
                    const Gap(10),
                    InputField.text(
                      controller: organizationController,
                      inputIcon: SvgPicture.asset(
                        // 'assets/images/svg/Organization Icon.svg',
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
                    const Gap(16),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Consumer(
                          builder: (context, ref, _) {
                            final selectedInterests =
                                ref.watch(recruiterInterestsNotifierProvider);

                            return FocusButton(
                              controller: interestController,
                              filled: true,
                              hintText: selectedInterests.isNotEmpty
                                  ? null
                                  : 'Choose your Interests',
                              child: selectedInterests.isNotEmpty
                                  ? SizedBox(
                                      height: 50,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: selectedInterests
                                            .map(
                                              (interest) => Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: ColorPallete
                                                            .strawberryGlaze,
                                                      ),
                                                    ),
                                                    child: Text(interest),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    )
                                  : null,
                              onTap: () async {
                                final List<CategoryModel> interests = await ref
                                    .watch(categoriesNotifierProvider.future);

                                if (context.mounted) {
                                  // await showInterestListModal(context, interests);
                                  await GlazeModal.showInterestListModal(
                                    context,
                                    interests,
                                  );
                                }
                                setState(() {});
                              },
                            );
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Save',
                      onPressed: () {},
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
