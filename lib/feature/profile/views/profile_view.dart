import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/profile/widgets/profile_users_interest_list.dart';
import 'package:glaze/data/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/router.dart';
import '../../../data/models/user/user_model.dart';
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
              ),
              const Gap(8),
              Text(
                value.maybeWhen(
                  orElse: () => '',
                  data: (data) {
                    return '@${data?.username ?? data?.usernameId.toString()}';
                  },
                ),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: width * 0.6,
                child: Text(
                  value.maybeWhen(
                    orElse: () => '',
                    data: (data) => data?.bio ?? '',
                  ),
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
              const Gap(20),
              // Consumer(
              //   builder: (context, ref, _) {
              //     final userValue = ref.watch(loggedInUserNotifierProvider);

              //     return value.maybeWhen(
              //       orElse: () {
              //         return const SizedBox.shrink();
              //       },
              //       data: (data) {
              //         if (data?.id ==
              //             userValue.maybeWhen(
              //                 orElse: () => '', data: (data) => data?.id)) {
              //           return const SizedBox.shrink();
              //         }

              //         return Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //           child: Column(
              //             children: [
              //               PrimaryButton(
              //                 label: 'Follow',
              //                 onPressed: () {},
              //               ),
              //               const SizedBox(height: 20),
              //             ],
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
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
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: ColorPallete.strawberryGlaze,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Glaze',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.start,
                      children: value.maybeWhen(
                        orElse: () => [],
                        data: (glaze) {
                          final glazes = glaze?.glazes;
                          return glazes
                                  ?.map(
                                    (glaze) => const GlazeButton(
                                      label: '🍩',
                                    ),
                                  )
                                  .toList() ??
                              [];
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'General Settings',
                backgroundColor: Colors.transparent,
                onPressed: () =>
                    router.push(const GeneralSettingsRoute().location),
              ),
              PrimaryButton(
                label: 'Log Out',
                backgroundColor: Colors.transparent,
                onPressed: () async {
                  ref.read(logoutNotifierProvider.notifier).logout();
                },
                isLoading: ref.watch(logoutNotifierProvider).isLoading,
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
