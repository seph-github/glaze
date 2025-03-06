import 'package:flutter/material.dart';
import 'package:glaze/color_pallete.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorPallete.blackPearl,
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
