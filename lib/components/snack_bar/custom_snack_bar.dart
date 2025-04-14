import 'package:flutter/material.dart';

import '../../core/styles/color_pallete.dart';

class CustomSnackBar {
  static void showSnackBar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        backgroundColor: ColorPallete.magenta,
        content: Text(
          'Error: $message',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
