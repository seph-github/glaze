import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/repository/user_repository/user_repository.dart';

import '../widgets/profile_interaction_card.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(userNotifierProvider);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorPallete.strawberryGlaze,
                          width: 5,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/no-profile-picture-icon.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorPallete.parlourRed,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.edit,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  value.maybeWhen(
                    orElse: () => '',
                    data: (data) => data?.username ?? '',
                  ),
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
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
                const Gap(4),
                SizedBox(
                  height: 20,
                  width: width * 0.75,
                  child: ListView.separated(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const ProfileHobbiesList();
                    },
                    separatorBuilder: (context, index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber,
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                const SizedBox(height: 20),
                const ProfileInteractionCard(),
                // PrimaryButton(
                //   label: 'Save Changes',
                //   onPressed: () {},
                // ),
                // const SizedBox(height: 20),
                // PrimaryButton(
                //   label: 'Show Tutorial',
                //   backgroundColor: Colors.transparent,
                //   onPressed: () {},
                // ),
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     GlazeButton(
                      //       label: '🍩',
                      //     ),
                      //     GlazeButton(
                      //       label: '✨',
                      //     ),
                      //     GlazeButton(
                      //       label: '🌀',
                      //     ),
                      //     GlazeButton(
                      //       label: '💎',
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 130.0,
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achiements',
                        style: TextStyle(fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AchievementsButton(
                            label: '🍩',
                          ),
                          AchievementsButton(
                            label: '✨',
                          ),
                          AchievementsButton(
                            label: '🌀',
                          ),
                          AchievementsButton(
                            label: '💎',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Moments',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 20,
                      children: value.maybeWhen(
                        orElse: () => [],
                        data: (data) {
                          final video = data?.videos;
                          return video
                                  ?.map(
                                    (video) => Container(
                                      clipBehavior: Clip.antiAlias,
                                      height: 200,
                                      width: MediaQuery.sizeOf(context).width /
                                          2.5,
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
                                      child: Image.network(
                                        video.thumbnailUrl,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  )
                                  .toList() ??
                              [];
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Log Out',
                  backgroundColor: Colors.transparent,
                  onPressed: () => ref.watch(authServiceProvider).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileHobbiesList extends StatelessWidget {
  const ProfileHobbiesList({
    super.key,
    this.hobby,
    this.icon = Icons.sports_baseball_outlined,
  });

  final String? hobby;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18.0,
        ),
        const Gap(5),
        Text(
          hobby ?? 'Hobby',
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

class AchievementsButton extends StatelessWidget {
  const AchievementsButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 80.0,
      padding: const EdgeInsets.only(left: 8.0),
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
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 32,
        ),
      ),
    );
  }
}
