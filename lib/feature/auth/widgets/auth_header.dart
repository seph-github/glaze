import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.isLogin,
  });

  final ValueNotifier<bool> isLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isLogin.value ? 'Welcome Back' : 'Get Started',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
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
      ],
    );
  }
}
