import 'package:flutter/material.dart';
import 'package:glaze/components/input_field.dart';
import 'package:glaze/styles/color_pallete.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, String? redirect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.blackPearl,
      body: SafeArea(
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
            ),
            const SizedBox(
              height: 16,
            ),
            InputField.password(
              label: 'Password',
              hintText: 'Enter your password',
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPallete.strawberryGlaze,
              ),
              child: const Text('Login'),
            ),
            const Text('Don\'t have an account? Sign up'),
            const Text('OR CONTINUE WITH'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Continue Anonymously'),
            ),
          ],
        ),
      ),
    );
  }
}
