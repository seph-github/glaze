import 'package:flutter/material.dart';

import '../../../core/styles/color_pallete.dart';

class ShareOptionButton extends StatelessWidget {
  const ShareOptionButton({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: ColorPallete.secondaryColor,
      ),
      width: 56.0,
      height: 56.0,
      padding: const EdgeInsets.all(12.0),
      child: child,
    );
  }
}
