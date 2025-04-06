import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/profile/widgets/profile_users_interest_list.dart';
import 'package:glaze/data/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/fonts.gen.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/router.dart';
import '../../../data/models/profile/user_model.dart';
import '../../../gen/assets.gen.dart';
import '../widgets/profile_achievements_card.dart';
import '../widgets/profile_interaction_card.dart';
import '../widgets/profile_moments_card.dart';
import '../widgets/user_profile_image_widget.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserModel?> value = ref.watch(userNotifierProvider);

    final router = GoRouter.of(context);

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    return LoadingLayout(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Profile'),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: FontFamily.hitAndRun,
            ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              width: 46.0,
              height: width,
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: ColorPallete.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(Assets.images.svg.messageIcon.path),
            ),
          ),
          const Gap(12.0),
          InkWell(
            borderRadius: BorderRadius.circular(64.0),
            radius: 64.0,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              router.push(const GeneralSettingsRoute().location);
            },
            child: Container(
              width: 46.0,
              height: width,
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: ColorPallete.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(Assets.images.svg.settingsIcon.path),
            ),
          ),
          const Gap(16.0),
        ],
      ),
      isLoading: ref.watch(logoutNotifierProvider).isLoading,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserProfileImageWidget(
                imageUrl: value.maybeWhen(
                  orElse: () => '',
                  data: (data) => data?.profileImageUrl,
                ),
                username: value.maybeWhen(
                  orElse: () => '',
                  data: (data) => data?.username,
                ),
                bio: value.maybeWhen(
                  orElse: () => '',
                  data: (data) => data?.bio,
                ),
              ),
              const ProfileUsersInterestList(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ProfileInteractionCard(
                  following: value.maybeWhen(
                    orElse: () => 0,
                    data: (data) {
                      return data?.totalFollowing ?? 0;
                    },
                  ),
                  followers: value.maybeWhen(
                    orElse: () => 0,
                    data: (data) => data?.totalFollowers ?? 0,
                  ),
                  glazes: value.maybeWhen(
                    orElse: () => 0,
                    data: (data) => data?.totalGlazes ?? 0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PrimaryButton(
                      width: width * 0.45,
                      label: 'Edit Profile',
                      icon: SvgPicture.asset(
                        Assets.images.svg.editProfileIcon.path,
                      ),
                      backgroundColor: ColorPallete.secondaryColor,
                      onPressed: () {
                        router.push(
                          ProfileUserFormRoute(
                            id: value.maybeWhen(
                              orElse: () => '',
                              data: (data) => data?.id ?? '',
                            ),
                          ).location,
                        );
                      },
                    ),
                    PrimaryButton(
                      width: width * 0.45,
                      label: 'Share Profile',
                      icon: SvgPicture.asset(
                        Assets.images.svg.shareIcon.path,
                      ),
                      backgroundColor: ColorPallete.secondaryColor,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const ProfileAchievementsCard(),
              const SizedBox(height: 20),
              ProfileMomentsCard(
                isLoading: ref.watch(userNotifierProvider).isLoading,
                videos: value.maybeWhen(
                  orElse: () => [],
                  data: (data) => data?.videos ?? [],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Log Out',
                backgroundColor: Colors.transparent,
                onPressed: () async {
                  ref.read(logoutNotifierProvider.notifier).logout();
                },
                // isLoading: ref.watch(logoutNotifierProvider).isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlazeButton extends StatelessWidget {
  const GlazeButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      width: 80.0,
      decoration: BoxDecoration(
        color: Colors.white12,
        border: const Border.fromBorderSide(
          BorderSide(
            color: ColorPallete.strawberryGlaze,
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
