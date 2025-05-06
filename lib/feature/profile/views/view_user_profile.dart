import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/data/models/follows/follow.dart';
import 'package:glaze/data/repository/follows_repository/follow_repository_provider.dart';
import 'package:glaze/feature/profile/provider/profile_provider.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../auth/services/auth_services.dart';
import '../../settings/providers/settings_theme_provider.dart';
import '../widgets/profile_achievements_card.dart';
import '../widgets/profile_interaction_card.dart';
import '../widgets/profile_moments_card.dart';
import '../widgets/profile_users_interest_list.dart';
import '../widgets/user_profile_image_widget.dart';

class ViewUserProfile extends HookConsumerWidget {
  const ViewUserProfile({
    super.key,
    required this.id,
    this.controller,
  });

  final String id;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    const ColorFilter colorFilter = ColorFilter.mode(
      ColorPallete.lightBackgroundColor,
      BlendMode.srcIn,
    );

    final GoRouter router = GoRouter.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final viewMode = useState<bool>(false);
    final user = useState<User?>(null);
    final userId = useState<String>('');
    final isCurrentUser = useState<bool>(user.value?.id == id);

    useEffect(() {
      Future.microtask(() async {
        await ref.read(profileNotifierProvider.notifier).viewUserProfile(id);
      });
      user.value = AuthServices().currentUser!;
      userId.value = user.value?.id ?? '';
      viewMode.value = isCurrentUser.value;

      return null;
    }, []);

    final state = ref.watch(profileNotifierProvider);

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: AppBarWithBackButton(
        onBackButtonPressed: () async {
          router.pop();
        },
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserProfileImageWidget(
                imageUrl: state.viewUserProfile?.profileImageUrl,
                username: state.viewUserProfile?.username,
                bio: state.viewUserProfile?.bio,
              ),
              ProfileUsersInterestList(
                interests: state.viewUserProfile?.interests,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ProfileInteractionCard(
                  followers: state.viewUserProfile?.followers ?? [],
                  following: state.viewUserProfile?.following ?? [],
                  glazes: state.viewUserProfile?.glazes ?? [],
                ),
              ),
              const Gap(20),
              if (!viewMode.value)
                Consumer(
                  builder: (context, ref, _) {
                    final followedState = ref.read(
                      fetchFollowedUserNotifierProvider.call(userId.value),
                    );

                    final List<Follow> followedUsers = followedState.maybeWhen(
                      orElse: () => [],
                      data: (data) => data ?? [],
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrimaryButton(
                                isLoading: ref
                                    .watch(
                                      fetchFollowedUserNotifierProvider.call(userId.value),
                                    )
                                    .isLoading,
                                backgroundColor: followedUsers.any((follow) => follow.followingId == id) ? Colors.grey : ColorPallete.magenta,
                                label: followedUsers.any((follow) => follow.followingId == id) ? 'Unfollow' : 'Follow',
                                onPressed: () async {
                                  await ref
                                      .read(followUserNotifierProvider.notifier)
                                      .onFollowUser(
                                        followerId: userId.value,
                                        followingId: id,
                                      )
                                      .whenComplete(
                                        () => ref.refresh(
                                          fetchFollowedUserNotifierProvider.call(userId.value),
                                        ),
                                      );
                                },
                                width: width * 0.75,
                              ),
                              const Gap(5),
                              SvgPicture.asset(
                                Assets.images.svg.messageIcon.path,
                                colorFilter: isLightTheme ? colorFilter : null,
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
                  isLoading: state.isLoading,
                  videos: state.viewUserProfile?.videos ?? [],
                  isCurrentUser: isCurrentUser.value,
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
