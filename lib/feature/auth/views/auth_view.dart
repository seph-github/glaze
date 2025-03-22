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

class AuthView extends HookWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final size = useMemoized(() => MediaQuery.of(context).size);
    final providerController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final toggleItems = useState<List<String>>(['Email', 'Phone']);
    final itemsValue = useState<List<bool>>([true, false]);
    final selectedIndex = useState<int>(0);
    final isLogin = useState<bool>(true);

    final initialPage = useState<int>(0);

    final List<Color> colors = [
      Colors.white10,
      Colors.white12,
      Colors.white24,
      Colors.white30,
      Colors.white38,
      Colors.white54,
      Colors.white60,
      Colors.white70,
    ];

    final List<double> stops = [
      0.3,
      0.4,
      0.45,
      0.5,
      0.6,
      0.7,
      0.75,
      0.9,
    ];

    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          backgroundColor: ColorPallete.blackPearl,
          body: SafeArea(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      isLogin.value ? 'Welcome Back' : 'Get Started',
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      isLogin.value
                          ? 'Quick & secure access to your account\nwith email or phone number'
                          : 'Create your account easily, secure your profile\n&start sharing your moments hassle-free!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const Gap(20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(62.0),
                        color: ColorPallete.slateViolet,
                      ),
                      child: ToggleButtons(
                        tapTargetSize: MaterialTapTargetSize.padded,
                        constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minHeight: 60.0,
                        ),
                        isSelected: itemsValue.value,
                        borderColor: Colors.transparent,
                        fillColor: Colors.transparent,
                        selectedColor: Colors.white,
                        selectedBorderColor: Colors.transparent,
                        onPressed: (index) {
                          if (index == 0) {
                            itemsValue.value = [true, false];
                          } else {
                            itemsValue.value = [false, true];
                          }
                          selectedIndex.value = index;
                        },
                        children: toggleItems.value
                            .map(
                              (item) => Container(
                                alignment: Alignment.center,
                                width: (size.width / 2.229),
                                margin: const EdgeInsets.all(2.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.0),
                                  color: itemsValue.value[
                                          toggleItems.value.indexOf(item)]
                                      ? ColorPallete.blackPearl
                                      : Colors.transparent,
                                ),
                                child: Text(item),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const Gap(30),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: size.width * 0.25,
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: stops,
                            ),
                          ),
                        ),
                        Text(
                          'OR CONTINUE WITH',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                  ),
                        ),
                        Container(
                          width: size.width * 0.25,
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors.reversed.toList(),
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: stops,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    PrimaryButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        router.pushReplacement(const HomeRoute().location);
                      },
                      label: 'Continue Anonymously',
                      backgroundColor: ColorPallete.slateViolet,
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
