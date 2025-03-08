import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/styles/color_pallete.dart';

class PrimaryButton extends HookWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handlePressed() async {
      if (onPressed != null) {
        isLoading.value = true;
        try {
          await onPressed!();
        } finally {
          isLoading.value = false;
        }
      }
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading.value ? null : handlePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPallete.strawberryGlaze,
        ),
        child: isLoading.value
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(label),
      ),
    );
  }
}
