import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/feature/auth/providers/auth_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/input_field.dart';
import '../../../config/enum/profile_type.dart';
import '../../../core/routing/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../providers/initial_app_use.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_sso_widget.dart';

class AuthView extends HookConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();

    final toggleItems = useState<List<String>>([
      'Email',
      'Phone'
    ]);

    final selectedIndex = useState<int>(0);
    final isLogin = useState<bool>(true);
    final agreedToTermsAndCon = useState<bool>(false);
    final recruitingTalent = useState<bool>(false);
    final hasCompletedInitialAppUse = useState<bool>(false);

    Future<void> loginHandler() async {
      if (toggleItems.value[selectedIndex.value] == 'Phone') {
      } else {
        await ref.read(authNotifierProvider.notifier).signInWithEmailPassword(
              email: emailController.text,
              password: passwordController.text,
            );
      }
    }

    Future<void> signupHandler() async {
      final ProfileType profileType;
      if (recruitingTalent.value) {
        profileType = ProfileType.recruiter;
      } else {
        profileType = ProfileType.user;
      }

      await ref.read(authNotifierProvider.notifier).signUp(
            username: usernameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            password: passwordController.text.trim(),
            profileType: profileType,
          );
    }

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        if (isLogin.value) {
          loginHandler();
        } else {
          signupHandler();
        }
      }
    }

    Future<void> onAnonymousSignin(WidgetRef ref) async {
      await ref.read(authNotifierProvider.notifier).anonymousSignin();
    }

    useEffect(
      () {
        hasCompletedInitialAppUse.value = ref.read(initialAppUseProvider).completedInitialAppUse;

        return null;
      },
      [],
    );

    ref.listen(
      authNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(context, message: errorMessage);
        }
      },
    );

    final state = ref.watch(authNotifierProvider);

    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
      return null;
    }

    Widget buildLoginItems() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField.email(
            inputIcon: SvgPicture.asset(Assets.images.svg.emailIcon.path),
            hintText: toggleItems.value[0],
            controller: emailController,
            validator: validateEmail,
          ),
          const Gap(16),
          InputField.password(
            inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
            hintText: 'Enter your password',
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
        ],
      );
    }

    Widget buildSignupItems() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField.text(
            inputIcon: SvgPicture.asset(Assets.images.svg.profileIcon.path),
            hintText: 'Choose a username',
            controller: usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              } else if (value.length < 3) {
                return 'Username must be at least 3 characters long';
              } else if (value.length > 20) {
                return 'Username must be less than 20 characters long';
              } else if (RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return null;
              } else {
                return 'Username can only contain letters, numbers, and underscores';
              }
            },
          ),
          const Gap(16),
          InputField.email(
            inputIcon: SvgPicture.asset(Assets.images.svg.emailIcon.path),
            hintText: toggleItems.value[0],
            controller: emailController,
            validator: validateEmail,
          ),
          const Gap(16),
          InputField.password(
            inputIcon: SvgPicture.asset(Assets.images.svg.passwordIcon.path),
            hintText: 'Enter your password',
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
        ],
      );
    }

    return LoadingLayout(
      isLoading: state.isLoading,
      child: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const Gap(20),
                AuthHeader(
                  isLogin: isLogin,
                  isCompleteInitSetup: hasCompletedInitialAppUse,
                ),
                const Gap(30),
                if (isLogin.value) buildLoginItems() else buildSignupItems(),
                const Gap(16),
                if (isLogin.value)
                  GestureDetector(
                    onTap: () {},
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot Password?'),
                    ),
                  ),
                if (!isLogin.value)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Checkbox(
                          value: agreedToTermsAndCon.value,
                          onChanged: (value) {
                            agreedToTermsAndCon.value = value ?? false;
                          },
                          checkColor: ColorPallete.backgroundColor,
                        ),
                        const Text('I agree to the terms and conditions'),
                      ],
                    ),
                  ),
                const Gap(30),
                PrimaryButton(
                  onPressed: (agreedToTermsAndCon.value && usernameController.text.isNotEmpty && (emailController.text.isNotEmpty || phoneController.text.isNotEmpty) && phoneController.text.isNotEmpty && passwordController.text.isNotEmpty) || isLogin.value ? () => onSubmit() : null,
                  label: isLogin.value ? 'Login' : 'Sign Up',
                ),
                const Gap(20),
                AuthSSOWidget(),
                const Gap(20),
                if (isLogin.value)
                  PrimaryButton(
                    onPressed: () {
                      context.go(const AuthPhoneSignInRoute().location);
                    },
                    label: 'Sign in with Phone',
                    backgroundColor: ColorPallete.primaryColor,
                  ),
                const Gap(20),
                if (!hasCompletedInitialAppUse.value)
                  PrimaryButton(
                    onPressed: () => onAnonymousSignin(ref),
                    label: 'Continue Anonymously',
                    backgroundColor: Colors.white12,
                  ),
                const Gap(20),
                if (!isLogin.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Are You Recruiting Talent?',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Switch.adaptive(
                        value: recruitingTalent.value,
                        onChanged: (value) {
                          recruitingTalent.value = value;
                        },
                      ),
                    ],
                  ),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin.value ? 'Don\'t have an account?' : 'Already have an account?',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        isLogin.value = !isLogin.value;
                        usernameController.clear();
                        emailController.clear();
                        phoneController.clear();
                        passwordController.clear();
                      },
                      child: Text(
                        isLogin.value ? ' Sign up' : ' Login',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
                const Gap(30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
