import 'package:flutter/material.dart';
import 'package:glaze/color_pallete.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
            const Text('Email'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    color: ColorPallete.whiteSmoke,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    width: 1 / 4,
                    color: ColorPallete.persianFable,
                  ),
                ),
              ),
            ),
            const Text('Password'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    color: ColorPallete.whiteSmoke,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    width: 1 / 4,
                    color: ColorPallete.persianFable,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
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
