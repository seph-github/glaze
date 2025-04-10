import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';

import '../../moments/widgets/upload_moments_card.dart';

class DashboardView extends HookWidget {
  const DashboardView({
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
    return LoadingLayout(
      bottomNavigationBar: NavigationBar(
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
            selectedIcon:
                SvgPicture.asset(Assets.images.svg.momentsFillIcon.path),
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
            selectedIcon:
                SvgPicture.asset(Assets.images.svg.profileFillIcon.path),
            label: 'Profile',
          )
        ],
        onDestinationSelected: goBranch,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(
            24.0,
          ),
          bottomRight: Radius.circular(
            24.0,
          ),
        ),
        child: _navigationShell,
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
