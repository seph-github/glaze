import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/inputs/phone_number_input.dart';
import 'package:glaze/feature/auth/providers/auth_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/utils/form_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/routing/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/throw_error_exception_helper.dart';

class AuthPhoneSignIn extends HookConsumerWidget {
  const AuthPhoneSignIn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final router = GoRouter.of(context);
    final GlobalKey<FormState> formKey = useMemoized(() => GlobalKey<FormState>());
    final FocusNode phonePickerFocusNode = FocusNode();

    final phoneController = useTextEditingController();

    final dialCodeController = useTextEditingController();

    ref.listen(
      authNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          throwAuthExceptionError(context, next);
        }

        if (next.otpSent) {
          router.push(
            const AuthVerifyPhoneRoute().location,
            extra: {
              'phone': phoneController.text,
              'dialCode': dialCodeController.text,
            },
          );
        }
      },
    );

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.png.glazeOnSplash.path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: LoadingLayout(
        backgroundColor: Colors.transparent,
        isLoading: state.isLoading,
        appBar: AppBarWithBackButton(
          onBackButtonPressed: () {
            ref.invalidate(authNotifierProvider);
            router.pop();
          },
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            decoration: BoxDecoration(
              color: ColorPallete.inputFilledColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in with Phone Number',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(16.0),
                Text(
                  'Enter your phone number to receive a verification code',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const Gap(16.0),
                Form(
                  key: formKey,
                  child: PhoneNumberInput(
                    phoneController: phoneController,
                    focusNode: phonePickerFocusNode,
                    dialCodeController: dialCodeController,
                    validator: validatePhone,
                  ),
                ),
                const Gap(32.0),
                PrimaryButton(
                  label: 'Send OTP',
                  onPressed: () {
                    phonePickerFocusNode.unfocus();

                    if (formKey.currentState?.validate() == true) {
                      formKey.currentState?.save();

                      final phoneNumber = dialCodeController.text.trim() + phoneController.text.trim();

                      ref.read(authNotifierProvider.notifier).signInWithPhone(
                            phoneNumber,
                          );
                    } else {
                      return;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
