import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/assets.gen.dart';

class GlazeNavBar extends StatelessWidget {
  const GlazeNavBar({
    super.key,
    required StatefulNavigationShell navigationShell,
    this.onDestinationSelected,
  }) : _navigationShell = navigationShell;

  final StatefulNavigationShell _navigationShell;
  final void Function(int)? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
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
          icon: SvgPicture.asset(Assets.images.svg.homeOutlined.path),
          selectedIcon: SvgPicture.asset(Assets.images.svg.homeFillIcon.path),
          label: 'Home',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(Assets.images.svg.momentsInactiveIcon.path),
          selectedIcon: SvgPicture.asset(Assets.images.svg.momentsFillIcon.path),
          label: 'Moments',
        ),
        NavigationDestination(
          icon: Container(
            width: 50.0,
            height: 50.0,
            margin: const EdgeInsets.only(top: 30),
            child: SvgPicture.asset(Assets.images.svg.addIcon.path),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(Assets.images.svg.shopOutlined.path),
          selectedIcon: SvgPicture.asset(Assets.images.svg.shopFillIcon.path),
          label: 'Shops',
        ),
        NavigationDestination(
          icon: SvgPicture.asset(Assets.images.svg.profileIcon.path),
          selectedIcon: SvgPicture.asset(Assets.images.svg.profileFillIcon.path),
          label: 'Profile',
        )
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }
}
