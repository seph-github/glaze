import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';

import '../../moments/widgets/upload_moments_card.dart';
import '../widgets/glaze_nav_bar.dart';

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

    path.value = router.state.matchedLocation;

    return Consumer(
      builder: (context, ref, _) {
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

        return LoadingLayout(
          bottomNavigationBar: GlazeNavBar(
            navigationShell: _navigationShell,
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
      },
    );
  }
}

Future<void> _showBottomSheet(BuildContext context) async {
  await showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return const SafeArea(
        child: CupertinoPopupSurface(
          child: UploadMomentsCard(),
        ),
      );
    },
  );
}
