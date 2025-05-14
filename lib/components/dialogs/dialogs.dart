import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

class Dialogs {
  static Future<void> createContentDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                onPressed?.call();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> dualActionContentDialog(
    BuildContext context, {
    required String title,
    required String content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                onConfirm?.call();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            TextButton(
              onPressed: () {
                onCancel?.call();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showBottomDialog(BuildContext context, {required Widget child}) async {
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
