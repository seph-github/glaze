import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/custom_tab_bar.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/data/repository/follows_repository/follow_repository_provider.dart';
import 'package:glaze/feature/auth/services/auth_services.dart';
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
      FollowingListWidget(following: state.profile?.following ?? []),
      FollowersListWidget(followers: state.profile?.followers ?? []),
      _buildGlazeWidget(state.profile?.glazes ?? []),
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
  const FollowersListWidget({super.key, required this.followers});

  final List<Interact> followers;
  @override
  Widget build(BuildContext context) {
    final followerStates = useState<Map<String, bool>>({
      for (final follower in followers) follower.id: false,
    });

    void toggleFollow(String id) {
      final current = followerStates.value[id] ?? false;
      followerStates.value = {
        ...followerStates.value,
        id: !current, // toggle the specific user
      };
    }

    return ListView.builder(
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        final isFollowed = followerStates.value[follower.id] ?? false;

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
          trailing: _buildFollowButton(
            id: follower.id,
            isFollowed: isFollowed,
            onPressed: () async {
              toggleFollow(follower.id);
            },
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
    final followedStates = useState<Map<String, bool>>({
      for (final followed in following) followed.id: true,
    });

    void toggleFollow(String id) {
      final current = followedStates.value[id] ?? false;
      followedStates.value = {
        ...followedStates.value,
        id: !current, // toggle the specific user
      };
    }

    return ListView.builder(
      itemCount: following.length,
      itemBuilder: (context, index) {
        final profileImageUrl = following[index].profileImageUrl;
        final followed = following[index];
        final isFollowed = followedStates.value[followed.id] ?? false;

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
          trailing: _buildFollowButton(
            id: followed.id,
            isFollowed: isFollowed,
            onPressed: () async {
              toggleFollow(followed.id);
            },
          ),
        );
      },
    );
  }
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
