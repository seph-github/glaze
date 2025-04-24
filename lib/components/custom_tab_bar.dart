import 'package:flutter/material.dart';
import 'package:glaze/feature/settings/providers/settings_theme_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomTabBar extends HookConsumerWidget {
  const CustomTabBar({super.key, this.controller, required this.length, this.onTap, required this.tabs, required this.tabViews});

  final TabController? controller;
  final int length;

  final Function(int)? onTap;
  final List<String> tabs;
  final List<Widget> tabViews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();

    return DefaultTabController(
      length: length,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: TabBar(
              controller: controller,
              onTap: onTap,
              // onTap: (value) {
              //   currentIndex = value;
              // },
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isLightTheme ? Colors.black.withValues(alpha: 0.01) : Colors.white.withValues(alpha: 0.01),
                    isLightTheme ? Colors.black.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.03),
                    isLightTheme ? Colors.black.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              textScaler: TextScaler.noScaling,
              tabs: tabs.map(
                (tab) {
                  return Tab(
                    child: Text(
                      tab,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: tabViews.map(
                (tab) {
                  return tab;
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
