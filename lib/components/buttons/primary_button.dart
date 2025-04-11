import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// import 'package:lottie/lottie.dart';

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
    this.height,
    this.width,
    this.icon,
  }) : borderRadius = borderRadius ?? 32.0;

  final String label;
  final void Function()? onPressed;
  final bool? isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final double? height;
  final double? width;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? ColorPallete.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading ?? false
            ? const CircularProgressIndicator(
                color: ColorPallete.whiteSmoke,
              )
            // Lottie.asset(
            //     'assets/lotties/donut_sprinkled.json',
            //     height: 32.0,
            //     width: 32.0,
            //   )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) icon ?? const SizedBox.shrink(),
                  const Gap(10),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
