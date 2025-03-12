import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/auth/providers/auth_service_provider.dart';
import 'package:glaze/feature/auth/views/login_view.dart';
import 'package:glaze/feature/auth/views/sign_up_view.dart';
import 'package:glaze/styles/color_pallete.dart';

import '../../../components/primary_button.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key, String? redirect});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  PageController pageController = PageController();
  int initialPage = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        pageController = PageController(initialPage: initialPage);
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.blackPearl,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.65,
                child: Image.asset('assets/images/glaze_icon_logo.png'),
              ),
              Flexible(
                flex: 1,
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    if (value != initialPage) {
                      initialPage = value;
                      emailController.clear();
                      passwordController.clear();
                      setState(() {});
                    }
                  },
                  children: [
                    LoginView(
                      emailController: emailController,
                      passwordController: passwordController,
                    ),
                    SignUpView(
                      emailController: emailController,
                      passwordController: passwordController,
                      usernameController: usernameController,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                onPressed: () async {
                  print('Validation ${formKey.currentState?.validate()}');
                  if (formKey.currentState?.validate() ?? false) {
                    print('username: ${usernameController.text}');
                    print('email: ${emailController.text}');
                    print('password: ${passwordController.text}');
                    try {
                      ref.watch(signupNotifierProvider.notifier).signup(
                            username: usernameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                          );
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
                // isLoading: ref.watch(loginNotifierProvider).isLoading,
                label: initialPage == 0 ? 'Login' : 'Sign Up',
              ),
              GestureDetector(
                onTap: () {
                  initialPage = initialPage == 0 ? 1 : 0;
                  pageController.animateToPage(
                    initialPage,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                  );
                  setState(() {});
                },
                child: initialPage == 0
                    ? const Text('Don\'t have an account? Sign up')
                    : const Text('Already have an account? Login'),
              ),
              const Text('OR CONTINUE WITH'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Continue Anonymously'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
