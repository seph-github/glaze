import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../feature/moments/widgets/upload_moments_card.dart';

class NestedNavigationScaffold extends HookWidget {
  const NestedNavigationScaffold({
    super.key,
    required StatefulNavigationShell navigationShell,
  }) : _navigationShell = navigationShell;

  final StatefulNavigationShell _navigationShell;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final path = useState<String>(router.state.matchedLocation);
    void goBranch(int index) async {
      if (index == 2) {
        await _showBottomSheet(context);
      } else {
        _navigationShell.goBranch(
          index,
          initialLocation: index != _navigationShell.currentIndex,
        );
      }
    }

    path.value = router.state.matchedLocation;
    return Scaffold(
      body: _navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationShell.currentIndex,
        indicatorColor: Colors.transparent,
        indicatorShape: null,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset('assets/images/svg/home_outlined.svg'),
            selectedIcon:
                SvgPicture.asset('assets/images/svg/home_fill_icon.svg'),
            label: 'Home',
          ),
          NavigationDestination(
            icon:
                SvgPicture.asset('assets/images/svg/moments_inactive_icon.svg'),
            selectedIcon:
                SvgPicture.asset('assets/images/svg/moments_fill_icon.svg'),
            label: 'Moments',
          ),
          NavigationDestination(
            icon: Container(
              width: 50.0,
              height: 50.0,
              margin: const EdgeInsets.only(top: 30),
              child: SvgPicture.asset('assets/images/svg/add_icon.svg'),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/images/svg/shop_inactive_icon.svg'),
            selectedIcon:
                SvgPicture.asset('assets/images/svg/shop_fill_icon.svg'),
            label: 'Shops',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/images/svg/profile_icon.svg'),
            selectedIcon:
                SvgPicture.asset('assets/images/svg/profile_fill_icon.svg'),
            label: 'Profile',
          )
        ],
        onDestinationSelected: goBranch,
      ),
    );
  }
}

Future<void> _showBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
    builder: (context) => const UploadMomentsCard(),
  );
}
