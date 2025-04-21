import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.isLogin,
    required this.isCompleteInitSetup,
  });

  final ValueNotifier<bool> isLogin;
  final ValueNotifier<bool> isCompleteInitSetup;

  @override
  Widget build(BuildContext context) {
    String buildWelcomeText() {
      if (isLogin.value && isCompleteInitSetup.value) {
        return 'Welcome Back';
      } else if (isLogin.value && !isCompleteInitSetup.value) {
        return 'Welcome';
      } else {
        return 'Get Started';
      }
    }

    String buildWelcomeSubText() {
      if (isLogin.value) {
        return 'Quick & secure access to your account\nwith email or phone number';
      } else {
        return 'Create your account easily, secure your profile\n&start sharing your moments hassle-free!';
      }
    }

    return Column(
      children: [
        Text(
          buildWelcomeText(),
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                // color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          buildWelcomeSubText(),
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
