import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
        final theme = ref.watch(settingsThemeProvider);

        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  filled: true,
                  hintText: 'Search for \'Basketball 🏀\'',
                  prefixIcon: SvgPicture.asset(
                    'assets/images/svg/search_icon.svg',
                    fit: BoxFit.scaleDown,
                    colorFilter: ColorFilter.mode(theme.colorScheme.onSurface.withValues(alpha: 0.6), BlendMode.srcIn),
                  ),
                  suffix: controller?.text != null
                      ? GestureDetector(
                          onTap: () {
                            controller?.clear();
                          },
                          child: SvgPicture.asset(
                            Assets.images.svg.closeIcon.path,
                            colorFilter: ColorFilter.mode(theme.colorScheme.onSurface.withValues(alpha: 0.6), BlendMode.srcIn),
                          ),
                        )
                      : null,
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
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  border: Border.all(
                    width: 1 / 2,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                child: SvgPicture.asset(
                  Assets.images.svg.filterIcon.path,
                  colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
