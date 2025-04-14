import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/config/enum/profile_type.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/data/repository/file_picker/file_picker_provider.dart';
import 'package:glaze/feature/profile/widgets/interest_choice_chip.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import '../../../components/buttons/focus_button.dart';
import '../../../components/inputs/input_field.dart';
// import '../../../components/modals/glaze_modals.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repository/category/category_repository.dart';
import '../../../gen/assets.gen.dart';
import '../models/profile.dart';
import '../provider/profile_interests_list_provider.dart';

class ProfileEditForm extends HookConsumerWidget {
  const ProfileEditForm({
    super.key,
    required this.id,
    this.data,
  });

  final String id;
  final Profile? data;
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final router = GoRouter.of(context);
    // final imageUrl = useState<String?>(null);
    File? file;

    final fullnameController = useTextEditingController(text: data?.fullName);
    final emailController = useTextEditingController(text: data?.email);
    final phoneController = useTextEditingController(text: data?.phoneNumber);
    final organizationController = useTextEditingController();
    final categories = useState<List<CategoryModel>>([]);
    final updatedSelectedInterests = useState<List<String>>([]);

    useEffect(() {
      Future.microtask(() async {
        categories.value =
            await ref.read(categoryRepositoryProvider).fetchCategories();
      });
      updatedSelectedInterests.value = data?.interests ?? [];
      return null;
    }, []);

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
                          image: data?.profileImageUrl != null
                              ? NetworkImage(
                                  data?.profileImageUrl ?? '',
                                )
                              : FileImage(
                                  file ?? File(''),
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: data?.profileImageUrl == null && file == null
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
                          ref.watch(filePickerNotifierProvider).value != null
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
                if (data?.role == ProfileType.recruiter.name)
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
                    updatedSelectedInterests.value = ref
                        .read(profileInterestsNotifierProvider.notifier)
                        .updateInterestsList(
                            updatedSelectedInterests.value, value);
                  },
                ),
                const Gap(32.0),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () {},
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
