import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/components/inputs/input_field.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/auth/providers/auth_provider/auth_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:glaze/utils/form_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/app_bar_with_back_button.dart';
import '../../../components/dialogs/dialogs.dart';

class AuthForgetPasswordView extends HookConsumerWidget {
  const AuthForgetPasswordView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final emailController = useTextEditingController();

    ref.listen(
      authNotifierProvider,
      (previous, next) async {
        if (next.isLoading) {
          return;
        }
        if (next.otpSent) {
          await Dialogs.createContentDialog(
            context,
            title: 'Email Sent',
            content: 'A password reset email has been sent to the provided address. Kindly review your inbox, including the spam/junk folder, to complete the process.',
            onPressed: () async {
              await router.push(
                const AuthConfirmTokenRoute().location,
                extra: emailController.text.trim(),
              );
            },
          );
        }
        if (next.error != null) {
          if (context.mounted) {
            CustomSnackBar.showSnackBar(
              context,
              content: Text(
                next.error.toString(),
              ),
            );
            ref.read(authNotifierProvider.notifier).clearError();
          }
        }
      },
    );

    return LoadingLayout(
      isLoading: ref.watch(authNotifierProvider).isLoading,
      appBar: AppBarWithBackButton(
        title: Text('Forget Password', style: Theme.of(context).textTheme.titleLarge),
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
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              children: <Widget>[
                const Gap(30.0),
                Text('We will send you an email with a link to reset your password, please enter the email associated with your account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: ColorPallete.borderColor)),
                const Gap(10.0),
                InputField.email(
                  hintText: 'Email',
                  controller: emailController,
                  inputIcon: SvgPicture.asset(Assets.images.svg.emailIcon.path),
                  validator: (value) => validateEmail(value),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  label: 'Reset Password',
                  borderRadius: 16,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      ref.read(authNotifierProvider.notifier).resetPassword(
                            emailController.text.trim().toLowerCase(),
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
