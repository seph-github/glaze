import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/components/input_field.dart';
import 'package:glaze/components/primary_button.dart';
import 'package:glaze/styles/color_pallete.dart';

import '../repository/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, String? redirect});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);

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
              InputField.email(
                label: 'Email',
                hintText: 'Enter your email',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              InputField.password(
                label: 'Password',
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
              PrimaryButton(
                onPressed: () async {
                  print('Login button pressed');
                  print('is valid form ${formKey.currentState?.validate()}');
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final result = await authRepository.login(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      print(result);
                      // Navigate to home page or show success message
                    } catch (e) {
                      // Handle login error
                      if (e is Exception) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $e')),
                          );
                        }
                      }
                    }
                  }
                },
                label: 'Login',
              ),
              const Text('Don\'t have an account? Sign up'),
              const Text('OR CONTINUE WITH'),
              ElevatedButton(
                onPressed: () {
                  // Perform anonymous login logic here
                },
                child: const Text('Continue Anonymously'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
