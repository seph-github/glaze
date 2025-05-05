import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../settings/providers/settings_theme_provider.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onTap,
    this.onFilterTap,
  });

  final TextEditingController? controller;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
        const double borderRadius = 16.0;

        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: Colors.white10,
                  filled: true,
                  hintText: 'Search for \'Basketball 🏀\'',
                  prefixIcon: SvgPicture.asset(
                    'assets/images/svg/search_icon.svg',
                    fit: BoxFit.scaleDown,
                  ),
                  suffix: controller?.text != null
                      ? GestureDetector(
                          onTap: () {
                            controller?.clear();
                          },
                          child: SvgPicture.asset(Assets.images.svg.closeIcon.path))
                      : null,
                  hintStyle: TextStyle(
                    color: isLightTheme ? ColorPallete.backgroundColor : ColorPallete.hintTextColor,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: isLightTheme ? ColorPallete.backgroundColor : ColorPallete.whiteSmoke,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: isLightTheme ? ColorPallete.backgroundColor : ColorPallete.whiteSmoke,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      width: 1 / 4,
                      color: isLightTheme ? ColorPallete.backgroundColor : ColorPallete.persianFable,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: const BorderSide(
                      width: 1,
                      color: ColorPallete.parlourRed,
                    ),
                  ),
                ),
                onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                onFieldSubmitted: (value) {
                  onTap?.call();
                },
              ),
            ),
            const Gap(10.0),
            GestureDetector(
              onTap: () {
                onFilterTap?.call();
              },
              child: Container(
                width: 56.0,
                height: 56.0,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLightTheme ? ColorPallete.backgroundColor : Colors.white10,
                ),
                child: SvgPicture.asset(
                  Assets.images.svg.filterIcon.path,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
