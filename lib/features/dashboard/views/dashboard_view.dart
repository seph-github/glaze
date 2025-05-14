import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/utils/network_util.dart';
import 'package:go_router/go_router.dart';
import 'package:glaze/features/dashboard/providers/dashboard_tab_controller_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/modals/glaze_modals.dart';
import '../widgets/glaze_nav_bar.dart';

class DashboardView extends HookConsumerWidget with WidgetsBindingObserver {
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
        await GlazeModal.showUploadContentModalPopUp(context);

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

    useEffect(() {
      final sub = ref.listenManual(
        connectivityResultProvider,
        (prev, next) {
          if (next
              case AsyncData(
                :final value
              )) {
            final isOffline = value.contains(ConnectivityResult.none);
            final isOnline = value.contains(ConnectivityResult.wifi) || value.contains(ConnectivityResult.mobile) || value.contains(ConnectivityResult.vpn);

            if (isOffline) {
              CustomSnackBar.showSnackBar(
                context,
                content: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Offline'),
                    Icon(Icons.wifi_off_rounded)
                  ],
                ),
              );
            } else if (isOnline) {
              CustomSnackBar.showSnackBar(
                context,
                content: const Text('Connected'),
              );
            }
          }
        },
      );

      return sub.close;
    }, []);

    return LoadingLayout(
      bottomNavigationBar: GlazeNavBar(
        onDestinationSelected: onTabSelected,
        navigationShell: navigationShell,
      ),
      child: navigationShell,
    );
  }
}
