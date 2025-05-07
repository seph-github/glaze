import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/custom_tab_bar.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/repository/follows_repository/follow_repository_provider.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
import 'package:glaze/feature/profile/models/profile/profile.dart';
import 'package:glaze/feature/profile/provider/profile_provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/navigation/router.dart';

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

class FollowersListWidget extends HookWidget {
  const FollowersListWidget({
    super.key,
    required this.followers,
    required this.following,
  });

  final List<Interact> followers;
  final List<Interact> following;
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    final followerStates = useState<Map<String, bool>>({
      for (final follower in followers) follower.id: following.any((item) => item.id == follower.id),
    });

    void toggleFollow(String id) {
      final current = followerStates.value[id] ?? false;
      followerStates.value = {
        ...followerStates.value,
        id: !current,
      };
    }

    return ListView.builder(
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        final isFollowed = followerStates.value[follower.id] ?? false;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            onTap: () => router.push(ViewUserProfileRoute(id: followers[index].id).location),
            leading: CircleAvatar(
              radius: 24,
              foregroundImage: CachedNetworkImageProvider(followers[index].profileImageUrl ?? ''),
            ),
            title: Text(
              '@${followers[index].username}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              followers[index].fullName ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ColorPallete.hintTextColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            trailing: Consumer(
              builder: (context, ref, _) {
                return ElevatedButton(
                  onPressed: () async {
                    if (!isFollowed) {
                      await ref.read(followUserNotifierProvider.notifier).onFollowUser(followerId: AuthServices().currentUser?.id ?? '', followingId: follower.id);
                      toggleFollow(follower.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromWidth(120),
                    backgroundColor: isFollowed ? ColorPallete.inputFilledColor : ColorPallete.primaryColor,
                  ),
                  child: Text(
                    isFollowed ? 'Message' : 'Follow',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FollowingListWidget extends HookWidget {
  const FollowingListWidget({super.key, required this.following});

  final List<Interact> following;
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    final followedStates = useState<Map<String, bool>>({
      for (final followed in following) followed.id: true,
    });

    void toggleFollow(String id) {
      final current = followedStates.value[id] ?? false;
      followedStates.value = {
        ...followedStates.value,
        id: !current,
      };
    }

    return ListView.builder(
      itemCount: following.length,
      itemBuilder: (context, index) {
        final profileImageUrl = following[index].profileImageUrl;
        final followed = following[index];
        final isFollowed = followedStates.value[followed.id] ?? false;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            onTap: () => router.push(
              ViewUserProfileRoute(id: following[index].id).location,
            ),
            leading: CircleAvatar(
              radius: 24,
              foregroundImage: profileImageUrl != null ? CachedNetworkImageProvider(profileImageUrl) : null,
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
              following[index].fullName ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ColorPallete.hintTextColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            trailing: _buildFollowButton(
              id: followed.id,
              isFollowed: isFollowed,
              onPressed: () async {
                toggleFollow(followed.id);
              },
            ),
          ),
        );
      },
    );
  }
}

class GlazersListWidget extends StatelessWidget {
  const GlazersListWidget({super.key, required this.glazes});

  final List<Glaze> glazes;
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return ListView.builder(
      itemCount: glazes.length,
      itemBuilder: (context, index) {
        final profileImageUrl = glazes[index].glazer.profileImageUrl;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () => router.push(
              ViewUserProfileRoute(id: glazes[index].glazer.id).location,
            ),
            leading: CircleAvatar(
              radius: 24,
              foregroundImage: profileImageUrl != null ? CachedNetworkImageProvider(profileImageUrl) : null,
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
                    text: ' has glazed you content showing strong engagements.',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: ColorPallete.hintTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildFollowButton({bool isFollowed = true, VoidCallback? onPressed, required String id}) {
  return Consumer(builder: (context, ref, _) {
    return ElevatedButton(
      onPressed: () async {
        onPressed?.call();
        await ref.read(followUserNotifierProvider.notifier).onFollowUser(followerId: AuthServices().currentUser?.id ?? '', followingId: id);
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromWidth(120),
        backgroundColor: isFollowed ? ColorPallete.inputFilledColor : ColorPallete.primaryColor,
      ),
      child: Text(
        isFollowed ? 'Unfollow' : 'Follow',
        style: const TextStyle(color: Colors.white),
      ),
    );
  });
}
