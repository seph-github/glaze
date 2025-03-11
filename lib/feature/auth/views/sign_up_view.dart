import 'package:flutter/widgets.dart';
import 'package:glaze/components/input_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField.text(
          label: 'Username',
          hintText: 'Choose a username',
          controller: usernameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
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
      ],
    );
  }
}
