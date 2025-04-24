import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/custom_tab_bar.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/profile/models/profile.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileInteractiveView extends HookConsumerWidget {
  const ProfileInteractiveView({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final List<String> tabs = [
      'Following',
      'Followers',
      'Glazes',
    ];

    final List<Widget> tabViews = [
      _buildFollowingWidget(state.profile?.following ?? []),
      _buildFollowersWidget(state.profile?.followers ?? []),
      _buildGlazeWidget(state.profile?.glazes ?? []),
    ];

    final tabController = useTabController(
      initialLength: tabs.length,
      initialIndex: initialIndex,
    );

    useEffect(() {
      // Future.microtask(() async => await ref.read(profileNotifierProvider.notifier).getUserInteractions());
      return;
    }, []);

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

Widget _buildFollowersWidget(List<Interact> followers) {
  return ListView.builder(
    itemCount: followers.length,
    itemBuilder: (context, index) {
      return ListTile(
        leading: CircleAvatar(
          radius: 24,
          foregroundImage: CachedNetworkImageProvider(followers[index].profileImageUrl),
        ),
        title: Text(
          '@${followers[index].username}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          followers[index].fullName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ColorPallete.hintTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Follow'),
        ),
      );
    },
  );
}

Widget _buildFollowingWidget(List<Interact> following) {
  return ListView.builder(
    itemCount: following.length,
    itemBuilder: (context, index) {
      final profileImageUrl = following[index].profileImageUrl;
      return ListTile(
        leading: CircleAvatar(
          radius: 24,
          foregroundImage: profileImageUrl.isNotEmpty ? CachedNetworkImageProvider(profileImageUrl) : null,
          backgroundColor: ColorPallete.blackPearl,
          child: SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              Assets.images.svg.profileIcon.path,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          '@${following[index].username}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          following[index].fullName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ColorPallete.hintTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Follow'),
        ),
      );
    },
  );
}

Widget _buildGlazeWidget(List<Glaze> glazes) {
  return ListView.builder(
    itemCount: glazes.length,
    itemBuilder: (context, index) {
      final profileImageUrl = glazes[index].glazer.profileImageUrl;
      return ListTile(
        leading: CircleAvatar(
          radius: 24,
          foregroundImage: profileImageUrl.isNotEmpty ? CachedNetworkImageProvider(profileImageUrl) : null,
          backgroundColor: ColorPallete.blackPearl,
          child: SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              Assets.images.svg.profileIcon.path,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '@${glazes[index].glazer.username}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextSpan(
                text: ' has glazed you content this times showing strong engagements.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ColorPallete.hintTextColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
