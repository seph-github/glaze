import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> createContentDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Column(
            children: [
              Text('This is a dialog'),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showBottomDialog(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {
            print('Called this method');
          },
          builder: (context) {
            return const Column(
              children: <Widget>[
                Text('Bottom Sheet'),
              ],
            );
          },
        );
      },
    );
  }
}
