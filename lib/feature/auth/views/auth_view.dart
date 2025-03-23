import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/input_field.dart';
import '../../../core/routing/router.dart';
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

    final initialPage = useState<int>(0);

    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          backgroundColor: ColorPallete.blackPearl,
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
                    const Gap(30),
                    PrimaryButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          try {
                            if (initialPage.value == 0) {
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
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        isLogin.value = !isLogin.value;
                      },
                      child: isLogin.value
                          ? const Text('Don\'t have an account? Sign up')
                          : const Text('Already have an account? Login'),
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
