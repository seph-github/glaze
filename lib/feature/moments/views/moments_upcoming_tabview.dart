import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/config/enum/challenge_type.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/moments/providers/moments_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../gen/fonts.gen.dart';
import '../../challenges/widgets/challenges_card.dart';

class MomentsUpcomingTabview extends HookConsumerWidget {
  const MomentsUpcomingTabview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(momentsNotifierProvider);
    final List<Challenge> upcomingChallenges = state.challenges.where((element) => element.type == ChallengeType.scheduled).toList();

    ref.listen(
      momentsNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(
            context,
            content: Text(errorMessage),
          );
        }
      },
    );

    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100.0,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Upcoming Challenges',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: FontFamily.robotoBold),
              ),
              Text(
                'Stay tuned for exciting challenges to test your skills!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ColorPallete.hintTextColor),
              ),
              const Gap(10),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ChallengesCard(
                challenge: upcomingChallenges[index],
                index: index,
              );
            },
            childCount: upcomingChallenges.length,
          ),
        ),
      ],
    );
  }
}
