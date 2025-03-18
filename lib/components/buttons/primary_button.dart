import 'package:flutter/material.dart';

import '../../core/styles/color_pallete.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final void Function()? onPressed;
  final bool? isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorPallete.strawberryGlaze,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: ColorPallete.strawberryGlaze,
            ),
          ),
        ),
        child: isLoading ?? false
            ? const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(label),
      ),
    );
  }
}
