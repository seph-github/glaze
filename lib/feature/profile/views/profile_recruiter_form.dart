import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/focus_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';

import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/config/strings/string_extension.dart';
import 'package:glaze/core/routing/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/models/category/category_model.dart';
import 'package:glaze/data/repository/category/category_repository.dart';
import 'package:glaze/data/repository/file_picker/file_picker_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/profile/provider/recruiter_interests_list_provider.dart';
import 'package:glaze/feature/profile/provider/recruiter_profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../core/result_handler/results.dart';
import '../widgets/recruiter_header_card.dart';
import '../widgets/recruiter_identification_card.dart';

class ProfileRecruiterForm extends ConsumerWidget {
  const ProfileRecruiterForm({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(getUserProfileNotifierProvider.call(userId));
    final recruiterProfileState =
        ref.watch(recruiterProfileNotifierProvider.call(userId));

    final File? file = ref.watch(filePickerNotifierProvider).value;

    final formKey = GlobalKey<FormState>();

    TextEditingController? fullnameController = TextEditingController();
    TextEditingController? emailController = TextEditingController();
    TextEditingController? phoneController = TextEditingController();
    TextEditingController? organizationController = TextEditingController();
    TextEditingController? interestController = TextEditingController();

    Future<void> handleSubmit() async {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        final result = await ref
            .read(updateRecruiterProfileNotifierProvider.notifier)
            .updateRecruiterProfile(
              userId: userId,
              fullName: fullnameController.text,
              email: emailController.text,
              phoneNumber: phoneController.text,
              organization: organizationController.text,
              interests: ref.watch(recruiterInterestsNotifierProvider),
              identificationUrl: file,
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
              title: 'Error',
              content: error.message.toString(),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          }
        }

        if (result is Success<String, Exception>) {
          if (context.mounted) {
            await Dialogs.createContentDialog(
              context,
              title: 'Success',
              content: result.value,
              onPressed: () {
                ref.invalidate(recruiterInterestsNotifierProvider);
                ref.invalidate(filePickerNotifierProvider);
                emailController.clear();
                interestController.clear();
                organizationController.clear();
                phoneController.clear();

                ref
                    .read(recruiterProfileProvider)
                    .setRecruiterProfileComplete(true)
                    .then(
                      (_) => ref.refresh(routerProvider),
                    );
              },
            );
          }
        }
      }
    }

    Future<void> showInterestListModal(
        BuildContext context, List<CategoryModel> interests) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: ColorPallete.inputFilledColor,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Consumer(
              builder: (context, ref, child) {
                final selectedInterests =
                    ref.watch(recruiterInterestsNotifierProvider);

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
                        ref
                            .read(recruiterInterestsNotifierProvider.notifier)
                            .addToInterestList(interestName);
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

    return state.when(
      data: (data) {
        emailController.text = data?.email ??
            recruiterProfileState.maybeWhen(
              orElse: () => '',
              data: (data) => data?.email ?? '',
            );
        phoneController.text = data?.phoneNumber ??
            recruiterProfileState.maybeWhen(
              orElse: () => '',
              data: (data) => data?.phoneNumber ?? '',
            );
        // organizationController.text = recruiterProfileState.maybeWhen(
        //   orElse: () => '',
        //   data: (data) => data?.phoneNumber ?? '',
        // );

        // List<String> interestList = recruiterProfileState.maybeWhen(
        //   orElse: () => [],
        //   data: (data) => data?.interests ?? [],
        // );

        // ref
        //     .read(recruiterInterestsNotifierProvider.notifier)
        //     .initializedInterest(interestList);

        return LoadingLayout(
          isLoading:
              ref.watch(updateRecruiterProfileNotifierProvider).isLoading,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const RecruiterHeaderCard(),
                      const Gap(16),
                      Text(
                        'Create Recruiter Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'Fill out the form below to become a verified recruiter. We’ll review your application within 24 hours.',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: ColorPallete.hintTextColor,
                            ),
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
                        readOnly: data?.email != null,
                        inputIcon: SvgPicture.asset(
                          'assets/images/svg/email_icon.svg',
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
                        initialValue: data?.phoneNumber ?? '',
                        readOnly: data?.phoneNumber != null,
                        inputIcon: SvgPicture.asset(
                          'assets/images/svg/phone_icon.svg',
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
                          'assets/images/svg/Organization Icon.svg',
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
                                                            BorderRadius
                                                                .circular(16),
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
                                  final List<CategoryModel> interests =
                                      await ref.watch(
                                          categoriesNotifierProvider.future);

                                  if (context.mounted) {
                                    await showInterestListModal(
                                        context, interests);
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          );
                        },
                      ),
                      const Gap(16),
                      RecruiterIdentificationCard(
                        recruiterIdentificationImageUrl:
                            recruiterProfileState.maybeWhen(
                          orElse: () => '',
                          data: (data) => data?.identificationUrl ?? '',
                        ),
                      ),
                      const Gap(16),
                      Text(
                        '* Please upload a government-issued ID or business card',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorPallete.hintTextColor,
                            ),
                      ),
                      const Gap(16),
                      PrimaryButton(
                        label: 'Start with \$10/month',
                        onPressed: handleSubmit,
                      ),
                    ],
                  ),
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
    );
  }
}
