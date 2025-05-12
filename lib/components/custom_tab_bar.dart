import 'package:flutter/material.dart';
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
    return DefaultTabController(
      length: length,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: TabBar(
              controller: controller,
              onTap: onTap,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.02),
                    Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.08),
                    Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.2),
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
