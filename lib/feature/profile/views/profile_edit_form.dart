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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/inputs/input_field.dart';
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
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = contentPickerNotifierProvider;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final router = GoRouter.of(context);

    final fullnameController = useTextEditingController(text: data?.fullName);
    final emailController = useTextEditingController(text: data?.email);
    final phoneController = useTextEditingController(text: data?.phoneNumber);
    final organizationController = useTextEditingController();
    final categories = useState<List<CategoryModel>>([]);
    final updatedSelectedInterests = useState<List<String>>([]);
    final currentImage = useState<String?>(data?.profileImageUrl);

    ref.listen(
      imageState,
      (prev, next) {
        if (next.image != null) {
          currentImage.value = next.image?.path;
        }
      },
    );

    useEffect(() {
      Future.microtask(() async {
        categories.value = await ref.read(categoryRepositoryProvider).fetchCategories();
      });
      updatedSelectedInterests.value = data?.interests ?? [];
      return null;
    }, []);

    return LoadingLayout(
      isLoading: ref.watch(imageState).isLoading,
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
                              : AssetImage(Assets.images.png.profilePlaceholder.path),
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
                    updatedSelectedInterests.value = ref.read(profileInterestsNotifierProvider.notifier).updateInterestsList(updatedSelectedInterests.value, value);
                  },
                ),
                const Gap(32.0),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    // await ref.read(profileNotifierProvider.notifier).updateProfile(id, email: , fullName: fullName, phoneNumber: phoneNumber, interestList: interestList, organization: organization, profileImage: profileImage, identification: identification, role: role)
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
