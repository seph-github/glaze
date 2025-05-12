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
    this.onBackButtonPressed,
    this.centerTitle = false,
    this.title,
    this.titleTextStyle,
    this.backgroundColor,
    this.leading,
    this.showBackButton = true,
  });

  final List<Widget>? actions;
  final VoidCallback? onBackButtonPressed;
  final bool? centerTitle;
  final Widget? title;
  final TextStyle? titleTextStyle;
  final Color? backgroundColor;
  final Widget? leading;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: showBackButton
          ? leading ??
              IconButton(
                icon: SvgPicture.asset(
                  Assets.images.svg.backArrowIcon.path,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: ColorPallete.inputFilledColor,
                  shape: const CircleBorder(),
                ),
                onPressed: onBackButtonPressed ??
                    () {
                      router.pop();
                    },
              )
          : null,
      centerTitle: centerTitle,
      title: title,
      titleTextStyle: titleTextStyle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
