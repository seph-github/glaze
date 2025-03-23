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
    double? borderRadius,
  }) : borderRadius = borderRadius ?? 32.0;

  final String label;
  final void Function()? onPressed;
  final bool? isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorPallete.magenta,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
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
