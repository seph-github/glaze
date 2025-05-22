import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../gen/assets.gen.dart';

class GlazeNavBar extends HookConsumerWidget {
  const GlazeNavBar({
    super.key,
    required StatefulNavigationShell navigationShell,
    this.onDestinationSelected,
  }) : _navigationShell = navigationShell;

  final StatefulNavigationShell _navigationShell;
  final void Function(int)? onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ColorFilter colorFilter = ColorFilter.mode(
      Theme.of(context).colorScheme.onSurfaceVariant,
      BlendMode.srcIn,
    );

    Widget navigationIcon({required String iconPath}) {
      return SvgPicture.asset(
        iconPath,
        colorFilter: colorFilter,
        height: 24,
      );
    }

    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedIndex: _navigationShell.currentIndex,
      indicatorColor: Colors.transparent,
      indicatorShape: null,
      overlayColor: const WidgetStatePropertyAll<Color>(
        Colors.transparent,
      ),
      destinations: [
        NavigationDestination(
          icon: navigationIcon(
            iconPath: Assets.images.svg.homeOutlined.path,
          ),
          selectedIcon: navigationIcon(
            iconPath: Assets.images.svg.homeFillIcon.path,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: navigationIcon(
            iconPath: Assets.images.svg.momentsInactiveIcon.path,
          ),
          selectedIcon: navigationIcon(
            iconPath: Assets.images.svg.momentsFillIcon.path,
          ),
          label: 'Moments',
        ),
        NavigationDestination(
          icon: Container(
            width: 65.0,
            height: 65.0,
            margin: const EdgeInsets.only(top: 12),
            child: SvgPicture.asset(
              Assets.images.svg.addIcon.path,
              colorFilter: colorFilter,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: navigationIcon(
            iconPath: Assets.images.svg.shopOutlined.path,
          ),
          selectedIcon: navigationIcon(
            iconPath: Assets.images.svg.shopFillIcon.path,
          ),
          label: 'Shop',
        ),
        NavigationDestination(
          icon: navigationIcon(
            iconPath: Assets.images.svg.profileIcon.path,
          ),
          selectedIcon: navigationIcon(
            iconPath: Assets.images.svg.profileFillIcon.path,
          ),
          label: 'Profile',
        )
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }
}
