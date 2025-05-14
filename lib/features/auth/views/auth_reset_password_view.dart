import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/app_bar_with_back_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/dialogs.dart';
import '../../../components/inputs/input_field.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/form_validators.dart';
import '../providers/auth_provider.dart';

class AuthResetPasswordView extends HookConsumerWidget {
  const AuthResetPasswordView({
    super.key,
    required this.accessToken,
    required this.email,
    required this.tokenHash,
  });

  final String accessToken;
  final String email;
  final String tokenHash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    ref.listen(authNotifierProvider, (prev, next) async {
      if (next.otpSent) {
        await Dialogs.createContentDialog(
          context,
          title: 'Success',
          content: 'Reset password completed. You will be sign in automatically.',
          onPressed: () => context.pop(),
        );
      }
    });

    return LoadingLayout(
      appBar: AppBarWithBackButton(
        title: Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        onBackButtonPressed: () {
          router.pop();
        },
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Gap(30.0),
                Text("You're almost there!", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorPallete.white)),
                const Gap(10.0),
                Text("Please enter your new password below to complete the reset process. For your security, make sure to choose a strong and unique password", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: ColorPallete.borderColor)),
                const Gap(10.0),
                Text("Once updated, you'll be signed in automatically.", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: ColorPallete.borderColor)),
                const SizedBox(height: 10),
                InputField.password(
                  hintText: 'New Password',
                  controller: passwordController,
                  inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
                  validator: (value) => validatePassword(value),
                ),
                const SizedBox(height: 10),
                InputField.password(
                  hintText: 'Confirm Password',
                  controller: confirmPasswordController,
                  inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
                  validator: (value) => validatePassword(value),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  label: 'Confirm',
                  borderRadius: 16,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (confirmPasswordController.text != passwordController.text) {
                        return await Dialogs.createContentDialog(
                          context,
                          title: 'Error',
                          content: 'Passwords do not match',
                          onPressed: () => router.pop(),
                        );
                      }

                      await ref.read(authNotifierProvider.notifier).updatePassword(
                            email: email,
                            password: confirmPasswordController.text.trim(),
                            token: accessToken,
                            tokenHash: tokenHash,
                          );
                    }
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
