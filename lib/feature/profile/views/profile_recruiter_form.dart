import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/drop_downs/custom_drop_down_menu.dart';
import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

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
    print(userId);
    final formKey = GlobalKey<FormState>();

    TextEditingController? fullnameController;
    TextEditingController? emailController;
    TextEditingController? phoneController;
    TextEditingController? organizationController;
    TextEditingController? interestController;

    final state = ref.watch(getUserProfileNotifierProvider.call(userId));

    return state.when(
      data: (data) {
        return LoadingLayout(
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
                      ),
                      const Gap(10),
                      InputField.email(
                        controller: emailController,
                        initialValue: data?.email ?? '',
                        inputIcon: SvgPicture.asset(
                          'assets/images/svg/email_icon.svg',
                        ),
                        hintText: 'Email address',
                        filled: true,
                      ),
                      const Gap(10),
                      InputField.text(
                        controller: phoneController,
                        inputIcon: SvgPicture.asset(
                          'assets/images/svg/phone_icon.svg',
                        ),
                        hintText: 'Phone number',
                        filled: true,
                      ),
                      const Gap(10),
                      InputField.text(
                        controller: organizationController,
                        inputIcon: SvgPicture.asset(
                          'assets/images/svg/Organization Icon.svg',
                        ),
                        hintText: 'Organization',
                        filled: true,
                      ),
                      const Gap(16),
                      CustomDropDownMenu(
                        controller: interestController,
                        menus: const ['Option 1', 'Option 2', 'Option 3'],
                        hintText: 'Choose your Interest',
                        filled: true,
                        onSelected: (value) {},
                      ),
                      const Gap(16),
                      const RecruiterIndentificationCard(),
                      const Gap(16),
                      Text(
                        '* Please upload a government-issued ID or business card',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorPallete.hintTextColor,
                            ),
                      ),
                      const Gap(16),
                      const PrimaryButton(label: 'Start with \$10/month'),
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
