import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/data/models/follows/follow.dart';
import 'package:glaze/data/repository/follows_repository/follow_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../data/repository/auth_repository/auth_repository_provider.dart';
import '../../../gen/assets.gen.dart';
import '../widgets/profile_achievements_card.dart';
import '../widgets/profile_interaction_card.dart';
import '../widgets/profile_moments_card.dart';
import '../widgets/profile_users_interest_list.dart';
import '../widgets/user_profile_image_widget.dart';

class ViewUserProfile extends HookWidget {
  const ViewUserProfile({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final viewMode = useState<bool>(false);
    final user = useState<User?>(null);
    final userId = useState<String>('');

    return Consumer(builder: (context, ref, _) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          user.value = await ref.watch(authServiceProvider).getCurrentUser();
          userId.value = user.value?.id ?? '';
          viewMode.value = user.value?.id == id;
        },
      );

      final state = ref.watch(
        getUserProfileNotifierProvider.call(id),
      );

      return LoadingLayout(
        isLoading: state.isLoading,
        appBar: const AppBarWithBackButton(),
        child: state.when(
          data: (data) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserProfileImageWidget(
                      imageUrl: data?.profileImageUrl,
                    ),
                    Text(
                      '@${data?.username ?? data?.usernameId.toString()}',
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
                    if (!viewMode.value)
                      Consumer(
                        builder: (context, ref, _) {
                          final followedState = ref.read(
                            fetchFollowedUserNotifierProvider
                                .call(userId.value),
                          );

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
                                                .call(userId.value),
                                          )
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
                                              followerId: userId.value,
                                              followingId: id,
                                            )
                                            .whenComplete(
                                              () => ref.refresh(
                                                fetchFollowedUserNotifierProvider
                                                    .call(userId.value),
                                              ),
                                            );
                                      },
                                      width: width / 1.25,
                                    ),
                                    const Gap(5),
                                    SvgPicture.asset(
                                      Assets.images.svg.messageIcon.path,
                                      width: 48.0,
                                    ),
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
