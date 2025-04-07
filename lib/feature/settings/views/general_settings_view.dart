import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/feature/settings/widgets/settings_menu_tile.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../widgets/settings_content_card.dart';

class GeneralSettingsView extends HookWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final lightmode = useState<bool>(false);
    return LoadingLayout(
      appBar: AppBar(
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
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: <Widget>[
            SettingsContentCard(
              cardLabel: 'General Settings',
              children: [
                SettingsMenuTile(
                  label: 'Light Mode',
                  icon: SvgPicture.asset(Assets.images.svg.lightModeIcon.path),
                  value: lightmode.value,
                  onChanged: (value) {
                    lightmode.value = value;
                  },
                ),
                SettingsMenuTile(
                  label: 'Language',
                  icon: SvgPicture.asset(Assets.images.svg.languageIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
                SettingsMenuTile(
                  label: 'Notification Settings',
                  icon: SvgPicture.asset(
                      Assets.images.svg.notificationSettingsIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
                SettingsMenuTile(
                  label: 'Privacy and Security',
                  icon: SvgPicture.asset(
                      Assets.images.svg.privacySecurityIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
              ],
            ),
            SettingsContentCard(
              cardLabel: 'Account Settings',
              children: [
                SettingsMenuTile(
                  label: 'Personal Details',
                  icon: SvgPicture.asset(
                      Assets.images.svg.personalDetailsIcon.path),
                  value: lightmode.value,
                  onChanged: (value) {
                    lightmode.value = value;
                  },
                ),
                SettingsMenuTile(
                  label: 'Donut Shop',
                  icon:
                      SvgPicture.asset(Assets.images.svg.shopInactiveIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
              ],
            ),
            SettingsContentCard(
              cardLabel: 'SUPPORT & LEGAL',
              children: [
                SettingsMenuTile(
                  label: 'Help Center',
                  icon: SvgPicture.asset(Assets.images.svg.helpCenterIcon.path),
                  value: lightmode.value,
                  onChanged: (value) {
                    lightmode.value = value;
                  },
                ),
                SettingsMenuTile(
                  label: 'Contact Support',
                  icon: SvgPicture.asset(Assets.images.svg.phoneIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
                SettingsMenuTile(
                  label: 'Terms & Conditions',
                  icon: SvgPicture.asset(
                      Assets.images.svg.termsConditionsIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
