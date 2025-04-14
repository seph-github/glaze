import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/feature/auth/providers/auth_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class AuthPhoneSignIn extends HookConsumerWidget {
  const AuthPhoneSignIn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);

    final phoneController = useTextEditingController();
    final codeController = useTextEditingController();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20, color: ColorPallete.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: ColorPallete.inputFilledColor,
        border: Border.all(
          color: ColorPallete.secondaryColor,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: ColorPallete.inputFilledColor,
      border: Border.all(color: ColorPallete.primaryColor),
      borderRadius: BorderRadius.circular(16),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: ColorPallete.primaryColor),
        borderRadius: BorderRadius.circular(16),
        color: ColorPallete.inputFilledColor,
      ),
    );

    ref.listen(
      authNotifierProvider,
      (prev, next) {
        if (next.error != null) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(
            context,
            message: errorMessage,
          );
        }
      },
    );

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: const AppBarWithBackButton(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                ' Welcome',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Quick & secure access to your account\nwith phone number',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const Gap(30),
              InputField.phone(
                controller: phoneController,
                hintText: '+1234567890',
                inputIcon: SvgPicture.asset(Assets.images.svg.phoneIcon.path),
              ),
              const Gap(16.0),
              Pinput(
                controller: codeController,
                keyboardType: TextInputType.number,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
              ),
              const Gap(32.0),
              PrimaryButton(
                label: 'Send OTP',
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signInWithPhone(
                        phoneController.text,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
