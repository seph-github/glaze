import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/feature/dashboard/providers/dashboard_tab_controller_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../moments/widgets/upload_moments_card.dart';
import '../widgets/glaze_nav_bar.dart';

class DashboardView extends HookConsumerWidget {
  const DashboardView({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(navigationShell.currentIndex);

    void onTabSelected(int index) async {
      if (index == 2 && context.mounted) {
        ref.read(dashboardTabControllerProvider.notifier).setTab(index);
        await _showBottomSheet(context);

        return;
      }

      if (index != currentIndex.value) {
        currentIndex.value = index;
        ref.read(dashboardTabControllerProvider.notifier).setTab(index);

        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      }
    }

    return LoadingLayout(
      bottomNavigationBar: GlazeNavBar(
        onDestinationSelected: onTabSelected,
        navigationShell: navigationShell,
      ),
      child: navigationShell,
    );
  }
}

Future<void> _showBottomSheet(BuildContext context) async {
  await showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return RepaintBoundary(
        child: SafeArea(
          bottom: false,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: const UploadMomentsCard(),
          ),
        ),
      );
    },
  );
}
