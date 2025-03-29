import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/data/models/follows/follow.dart';
import 'package:glaze/data/repository/follows_repository/follow_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/profile/provider/profile_view_mode_provider.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/auth_repository/auth_repository_provider.dart';
import '../widgets/profile_achievements_card.dart';
import '../widgets/profile_interaction_card.dart';
import '../widgets/profile_moments_card.dart';
import '../widgets/profile_users_interest_list.dart';
import '../widgets/user_profile_image_widget.dart';

class ViewUserProfile extends ConsumerWidget {
  const ViewUserProfile({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        bool viewMode =
            await ref.watch(authServiceProvider).getCurrentUser().then(
          (value) {
            return value?.id == id;
          },
        );

        ref
            .read(profileViewModeNotifierProvider.notifier)
            .changeViewMode(!viewMode);
      },
    );

    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(
        getUserProfileNotifierProvider.call(id),
      );
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: state.when(
          data: (data) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserProfileImageWidget(
                      imageUrl: data?.profileImageUrl,
                    ),
                    const Gap(8),
                    Text(
                      data?.username ?? '',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.6,
                      child: Text(
                        data?.bio ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const ProfileUsersInterestList(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ProfileInteractionCard(
                        followers: data?.totalFollowers ?? 0,
                        following: data?.totalFollowing ?? 0,
                        glazes: data?.totalGlazes ?? 0,
                      ),
                    ),
                    const Gap(20),
                    if (ref.watch(profileViewModeNotifierProvider))
                      Consumer(
                        builder: (context, ref, _) {
                          final userState =
                              ref.watch(loggedInUserNotifierProvider);

                          final String userId = userState.maybeWhen(
                              orElse: () => '', data: (data) => data?.id ?? '');

                          final followedState = ref.watch(
                              fetchFollowedUserNotifierProvider.call(userId));

                          final List<Follow> followedUsers =
                              followedState.maybeWhen(
                            orElse: () => [],
                            data: (data) => data ?? [],
                          );

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    PrimaryButton(
                                      isLoading: ref
                                          .watch(
                                              fetchFollowedUserNotifierProvider
                                                  .call(userId))
                                          .isLoading,
                                      backgroundColor: followedUsers.any(
                                              (follow) =>
                                                  follow.followingId == id)
                                          ? Colors.grey
                                          : ColorPallete.magenta,
                                      label: followedUsers.any((follow) =>
                                              follow.followingId == id)
                                          ? 'Unfollow'
                                          : 'Follow',
                                      onPressed: () async {
                                        await ref
                                            .read(followUserNotifierProvider
                                                .notifier)
                                            .onFollowUser(
                                              followerId: userState.maybeWhen(
                                                  orElse: () => '',
                                                  data: (data) =>
                                                      data?.id ?? ''),
                                              followingId: id,
                                            )
                                            .whenComplete(
                                              () => ref.refresh(
                                                fetchFollowedUserNotifierProvider
                                                    .call(userId),
                                              ),
                                            );
                                      },
                                      width: width / 1.25,
                                    ),
                                    const Gap(10),
                                    const Icon(Icons.message),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    const ProfileAchievementsCard(),
                    const SizedBox(height: 20),
                    Consumer(builder: (context, ref, _) {
                      return ProfileMomentsCard(
                        isLoading: ref.watch(userNotifierProvider).isLoading,
                        videos: data?.videos ?? [],
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Text('error occured\n$error, $stackTrace');
          },
        ),
      );
    });
  }
}
