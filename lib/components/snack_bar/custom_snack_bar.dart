import 'package:flutter/material.dart';

import '../../core/styles/color_pallete.dart';

class CustomSnackBar {
  static void showSnackBar(BuildContext context, {required Widget content, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        dismissDirection: DismissDirection.up,
        backgroundColor: ColorPallete.magenta,
        content: content,
        // content: Text(
        //   'Error: $message',
        //   style: const TextStyle(color: Colors.white),
        // ),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
}
