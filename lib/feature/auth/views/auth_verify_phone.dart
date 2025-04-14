import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../components/app_bar_with_back_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../templates/loading_layout.dart';
import '../providers/auth_provider.dart';
import '../providers/resend_code_timer_provider.dart';

class AuthVerifyPhone extends HookConsumerWidget {
  const AuthVerifyPhone({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final router = GoRouter.of(context);

    final codeController = useTextEditingController();
    final timerText = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    useEffect(() {
      timerNotifier.startTimer();
      return null;
    }, []);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: ColorPallete.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: ColorPallete.inputFilledColor,
        border: Border.all(
          width: 2,
          color: ColorPallete.white,
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
                  'Confirm your Phone Number',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(16.0),
                Text(
                  'Enter the OTP sent to your phone number',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
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
                const Gap(8.0),
                if (timerText == '00:00') ...[
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        timerNotifier.resetTimer(); // Reset the timer
                        timerNotifier.startTimer(); // Restart the timer
                        // Add logic to resend the OTP here
                      },
                      child: Text(
                        'Resend Code',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: ColorPallete.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Resend code in $timerText',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
                const Gap(32.0),
                PrimaryButton(
                  label: 'Verify',
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).verifyPhone(
                          phone: phoneNumber,
                          token: codeController.text,
                        );
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
