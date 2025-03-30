import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/input_field.dart';
import '../../../core/routing/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/auth_repository/auth_repository_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_provider_toggle_widget.dart';
import '../widgets/auth_sso_widget.dart';

class AuthView extends HookWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final providerController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final toggleItems = useState<List<String>>(['Email', 'Phone']);
    final itemsValue = useState<List<bool>>([true, false]);
    final selectedIndex = useState<int>(0);
    final isLogin = useState<bool>(true);
    final agreedToTermsAndCon = useState<bool>(false);
    final recruitingTalent = useState<bool>(false);

    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(),
                    AuthHeader(isLogin: isLogin),
                    const Gap(10),
                    AuthProviderToggleWidget(
                      toggleItems: toggleItems,
                      itemsValue: itemsValue,
                      selectedIndex: selectedIndex,
                    ),
                    const Gap(20),
                    if (!isLogin.value)
                      InputField.text(
                        inputIcon: SvgPicture.asset(
                            'assets/images/svg/profile_icon.svg'),
                        hintText: 'Choose a username',
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                    if (!isLogin.value) const Gap(20),
                    InputField.email(
                      inputIcon: toggleItems.value[selectedIndex.value] ==
                              'Email'
                          ? SvgPicture.asset('assets/images/svg/email_icon.svg')
                          : SvgPicture.asset(
                              'assets/images/svg/phone_icon.svg'),
                      hintText:
                          toggleItems.value[selectedIndex.value] == 'Email'
                              ? 'Enter your email'
                              : '+1234567890',
                      controller: providerController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your ${toggleItems.value[selectedIndex.value].toLowerCase()}';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                    InputField.password(
                      inputIcon: SvgPicture.asset(
                          'assets/images/svg/password_icon.svg'),
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
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          try {
                            if (isLogin.value) {
                              ref.read(loginNotifierProvider.notifier).login(
                                  email: providerController.text,
                                  password: passwordController.text);
                            } else {
                              ref.read(signupNotifierProvider.notifier).signup(
                                    username: usernameController.text,
                                    email: providerController.text,
                                    password: passwordController.text,
                                  );
                            }
                          } catch (e) {
                            if (e is Exception) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed: $e'),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      isLoading: isLogin.value
                          ? ref.watch(loginNotifierProvider).isLoading
                          : ref.watch(signupNotifierProvider).isLoading,
                      label: isLogin.value ? 'Login' : 'Sign Up',
                    ),
                    const Gap(20),
                    AuthSSOWidget(),
                    const Gap(20),
                    PrimaryButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        router.pushReplacement(const HomeRoute().location);
                      },
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
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
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
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin.value
                              ? 'Don\'t have an account?'
                              : 'Already have an account?',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            isLogin.value = !isLogin.value;
                          },
                          child: Text(
                            isLogin.value ? ' Sign up' : ' Login',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
