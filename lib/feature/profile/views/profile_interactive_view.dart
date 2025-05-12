import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/app_bar_with_back_button.dart';
import '../../../components/custom_tab_bar.dart';
import '../../templates/loading_layout.dart';
import '../models/profile/profile.dart';
import '../provider/profile_provider/profile_provider.dart';
import '../widgets/followers_list_widget.dart';
import '../widgets/following_list_widget.dart';
import '../widgets/glazers_list_widget.dart';

class ProfileInteractiveView extends HookConsumerWidget {
  const ProfileInteractiveView({
    super.key,
    this.initialIndex = 0,
    required this.followers,
    required this.following,
    required this.glazes,
  });

  final int initialIndex;
  final List<Interact> followers;
  final List<Interact> following;
  final List<Glaze> glazes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final List<String> tabs = [
      'Following',
      'Followers',
      'Glazes',
    ];

    final List<Widget> tabViews = [
      FollowingListWidget(following: following),
      FollowersListWidget(followers: followers, following: following),
      GlazersListWidget(glazes: glazes),
    ];

    final tabController = useTabController(
      initialLength: tabs.length,
      initialIndex: initialIndex,
    );

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: const AppBarWithBackButton(),
      child: SafeArea(
        child: CustomTabBar(
          length: tabs.length,
          controller: tabController,
          tabs: tabs,
          tabViews: tabViews,
        ),
      ),
    );
  }
}
