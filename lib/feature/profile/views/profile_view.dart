import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/feature/home/provider/video_feed_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/app_bar_with_back_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../config/enum/profile_type.dart';
import '../../../core/navigation/router.dart';
import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../../../providers/initial_app_use.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_services.dart';
import '../../settings/providers/settings_theme_provider.dart';
import '../../templates/loading_layout.dart';
import '../provider/profile_provider.dart';
import '../widgets/profile_achievements_card.dart';
import '../widgets/profile_interaction_card.dart';
import '../widgets/profile_moments_card.dart';
import '../widgets/profile_users_interest_list.dart';
import '../widgets/user_profile_image_widget.dart';

class ProfileView extends HookConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(settingsThemeProviderProvider) == ThemeData.light();
    final state = ref.watch(profileNotifierProvider);

    final router = GoRouter.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final User? user = AuthServices().currentUser;
    const double padding = 12.0;

    useEffect(
      () {
        Future.microtask(
          () async {
            await ref.read(profileNotifierProvider.notifier).fetchProfile(user?.id ?? '');
          },
        );
        return null;
      },
      [],
    );

    log('profile ${state.profile?.following}');

    return LoadingLayout(
      isLoading: state.isLoading,
      appBar: AppBarWithBackButton(
        showBackButton: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: const Text('Profile'),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: FontFamily.hitAndRun,
            ),
        actions: [
          if (state.profile?.role == ProfileType.recruiter.name)
            InkWell(
              onTap: () {},
              child: Container(
                width: 46.0,
                height: width,
                padding: const EdgeInsets.all(padding),
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
              padding: const EdgeInsets.all(padding),
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
      child: RefreshIndicator(
        onRefresh: () => ref.read(profileNotifierProvider.notifier).fetchProfile(user!.id),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserProfileImageWidget(
                  imageUrl: state.profile?.profileImageUrl,
                  username: state.profile?.username,
                  bio: state.profile?.bio,
                ),
                ProfileUsersInterestList(
                  interests: state.profile?.interests ?? [],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: ProfileInteractionCard(
                    following: state.profile?.following.length ?? 0,
                    followers: state.profile?.followers.length ?? 0,
                    glazes: state.profile?.glazes.length ?? 0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                        onPressed: () async {
                          await router.push(ProfileEditFormRoute(
                            id: state.profile?.id ?? '',
                          ).location);
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
                  isLoading: state.isLoading,
                  videos: state.profile?.videos ?? [],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Log Out',
                  backgroundColor: Colors.transparent,
                  foregroundColor: isLightTheme ? ColorPallete.backgroundColor : null,
                  onPressed: () async {
                    ref.invalidate(videoFeedNotifierProvider);
                    await ref.read(initialAppUseProvider).setInitialAppUseComplete(true).then(
                      (_) async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                      },
                    );
                  },
                ),
              ],
            ),
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
