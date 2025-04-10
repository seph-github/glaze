import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:go_router/go_router.dart';

import '../gen/assets.gen.dart';

class AppBarWithBackButton extends HookWidget implements PreferredSizeWidget {
  const AppBarWithBackButton({
    super.key,
    this.actions,
  });

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          Assets.images.svg.backArrowIcon.path,
        ),
        style: IconButton.styleFrom(
          backgroundColor: ColorPallete.inputFilledColor,
          shape: const CircleBorder(),
        ),
        onPressed: () {
          router.pop();
        },
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
