import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/styles/color_pallete.dart';

class FocusButton extends HookWidget {
  const FocusButton({
    super.key,
    this.child,
    this.onTap,
    this.hintText,
    this.helper,
    double? borderRadius,
    this.isLoading,
    this.validator,
  }) : borderRadius = borderRadius ?? 32.0;

  final Widget? child;
  final void Function()? onTap;
  final Widget? helper;
  final double borderRadius;
  final String? hintText;
  final bool? isLoading;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    return TextFormField(
      readOnly: true,
      focusNode: focusNode,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: ColorPallete.hintTextColor,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: ColorPallete.whiteSmoke,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: ColorPallete.whiteSmoke,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            width: 1 / 4,
            color: ColorPallete.persianFable,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            width: 1,
            color: ColorPallete.parlourRed,
          ),
        ),
        prefixIcon: child == null
            ? null
            : isLoading!
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: child)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
        helper: helper,
      ),
      onTap: () => onTap?.call(),
      onTapOutside: (event) {
        focusNode.unfocus();
      },
    );
  }
}
