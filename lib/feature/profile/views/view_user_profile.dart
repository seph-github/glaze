import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/data/repository/user_repository/user_repository.dart';

import '../../../components/buttons/primary_button.dart';
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
    final state = ref.watch(
      getUserProfileNotifierProvider.call(id),
    );

    final size = MediaQuery.sizeOf(context);
    final width = size.width;

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
                      glazes: data?.totalGlazes ?? 0,
                    ),
                  ),
                  const Gap(20),
                  Consumer(
                    builder: (context, ref, _) {
                      final userValue = ref.watch(loggedInUserNotifierProvider);

                      if (data?.id ==
                          userValue.maybeWhen(
                              orElse: () => '', data: (data) => data?.id)) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                PrimaryButton(
                                  label: 'Follow',
                                  onPressed: () {},
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
                  ProfileMomentsCard(
                    isLoading: ref.watch(userNotifierProvider).isLoading,
                    videos: data?.videos ?? [],
                  ),
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
  }
}
