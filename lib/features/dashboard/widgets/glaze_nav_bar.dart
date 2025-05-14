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
      Theme.of(context).colorScheme.primary,
      BlendMode.srcIn,
    );

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
          icon: SvgPicture.asset(
            Assets.images.svg.homeOutlined.path,
            colorFilter: colorFilter,
          ),
          selectedIcon: SvgPicture.asset(
            Assets.images.svg.homeFillIcon.path,
            colorFilter: colorFilter,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            Assets.images.svg.momentsInactiveIcon.path,
            colorFilter: colorFilter,
          ),
          selectedIcon: SvgPicture.asset(
            Assets.images.svg.momentsFillIcon.path,
            colorFilter: colorFilter,
          ),
          label: 'Moments',
        ),
        NavigationDestination(
          icon: Container(
            width: 50.0,
            height: 50.0,
            margin: const EdgeInsets.only(top: 30),
            child: SvgPicture.asset(
              Assets.images.svg.addIcon.path,
              colorFilter: colorFilter,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            Assets.images.svg.shopOutlined.path,
            colorFilter: colorFilter,
          ),
          selectedIcon: SvgPicture.asset(
            Assets.images.svg.shopFillIcon.path,
            colorFilter: colorFilter,
          ),
          label: 'Shop',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(
            Assets.images.svg.profileIcon.path,
            colorFilter: colorFilter,
          ),
          selectedIcon: SvgPicture.asset(
            Assets.images.svg.profileFillIcon.path,
            colorFilter: colorFilter,
          ),
          label: 'Profile',
        )
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }
}
