import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

class Dialogs {
  static Future<void> createContentDialog(BuildContext context,
      {required String title,
      required String content,
      VoidCallback? onPressed}) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            title,
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => onPressed?.call(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showBottomDialog(BuildContext context,
      {required Widget child}) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          backgroundColor: ColorPallete.blackPearl,
          dragHandleColor: ColorPallete.blackPearl,
          dragHandleSize: const Size(30.0, 8.0),
          enableDrag: true,
          builder: (context) {
            return child;
          },
        );
      },
    );
  }
}
