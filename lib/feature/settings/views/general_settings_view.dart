import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/settings/providers/settings_theme_provider.dart';
import 'package:glaze/feature/settings/widgets/settings_menu_tile.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/navigation/router.dart';
import '../../../core/services/secure_storage_services.dart';
import '../../../gen/assets.gen.dart';
import '../../../providers/initial_app_use.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/settings_content_card.dart';

class GeneralSettingsView extends HookConsumerWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final router = GoRouter.of(context);
    final isLightMode = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    final lightmode = useState<bool>(isLightMode);

    useEffect(() {
      lightmode.value = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
      return;
    }, []);

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: AppBarWithBackButton(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView(
          children: <Widget>[
            Consumer(
              builder: (context, ref, _) {
                return SettingsContentCard(
                  cardLabel: 'GENERAL SETTINGS',
                  children: [
                    SettingsMenuTile(
                      label: 'Light Mode',
                      icon: SvgPicture.asset(Assets.images.svg.lightModeIcon.path),
                      value: lightmode.value,
                      onChanged: (value) {
                        lightmode.value = value;
                        ref.read(settingsThemeProviderProvider.notifier).toggleTheme();
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
                      icon: SvgPicture.asset(Assets.images.svg.notificationSettingsIcon.path),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 24.0,
                      ),
                      onChanged: (value) => {},
                    ),
                    SettingsMenuTile(
                      label: 'Privacy and Security',
                      icon: SvgPicture.asset(Assets.images.svg.privacySecurityIcon.path),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 24.0,
                      ),
                      onChanged: (value) => {},
                    ),
                  ],
                );
              },
            ),
            SettingsContentCard(
              cardLabel: 'ACCOUNT SETTINGS',
              children: [
                SettingsMenuTile(
                  onTap: () => router.go(const PersonalDetailsRoute().location),
                  label: 'Account Details',
                  icon: SvgPicture.asset(Assets.images.svg.personalDetailsIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  value: lightmode.value,
                  onChanged: (value) {
                    lightmode.value = value;
                  },
                ),
                SettingsMenuTile(
                  label: 'Shop',
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
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
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  value: lightmode.value,
                  onChanged: (value) {
                    lightmode.value = value;
                  },
                ),
                SettingsMenuTile(
                  label: 'Contact Support',
                  icon: const Icon(
                    Icons.phone_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onChanged: (value) => {},
                ),
                SettingsMenuTile(
                  label: 'Terms & Conditions',
                  icon: SvgPicture.asset(Assets.images.svg.termsConditionsIcon.path),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 24.0,
                  ),
                  onTap: () => router.push(const TermsAndConditionRoute().location),
                ),
              ],
            ),
            SettingsContentCard(
              cardLabel: '',
              children: <Widget>[
                Consumer(builder: (context, ref, _) {
                  return SettingsMenuTile(
                    label: 'Log Out',
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                    trailing: const SizedBox.shrink(),
                    onTap: () async {
                      if (context.canPop()) {
                        await SecureCache.clear('user_profile');

                        await ref.read(initialAppUseProvider).setInitialAppUseComplete(true).then(
                          (_) async {
                            await ref.read(authNotifierProvider.notifier).signOut();
                          },
                        );
                      }
                    },
                  );
                }),
              ],
            ),
            const Gap(32.0),
          ],
        ),
      ),
    );
  }
}
