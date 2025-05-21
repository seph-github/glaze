import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/navigation/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/follows_repository/follow_repository_provider.dart';
import '../../auth/services/auth_services.dart';
import '../models/profile/profile.dart';

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
            onTap: () => router.push(ViewUserProfileRoute($extra: null, id: followers[index].id).location),
            leading: CircleAvatar(
              radius: 24,
              foregroundImage: CachedNetworkImageProvider(followers[index].profileImageUrl ?? ''),
            ),
            title: Text(
              '@${followers[index].username}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                  onPressed: () {
                    if (!isFollowed) {
                      ref.read(followUserNotifierProvider.notifier).onFollowUser(followerId: AuthServices().currentUser?.id ?? '', followingId: follower.id);
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
