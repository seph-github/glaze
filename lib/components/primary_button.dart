import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/styles/color_pallete.dart';

class PrimaryButton extends HookWidget {
  const PrimaryButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPallete.strawberryGlaze,
        ),
        child: Text(label),
      ),
    );
  }
}
