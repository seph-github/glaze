import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/config/enum/challenge_type.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/challenges/models/challenge/challenge.dart';
import 'package:glaze/features/moments/providers/moments_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../gen/fonts.gen.dart';
import '../../challenges/widgets/challenges_card.dart';
import '../widgets/challenge_shimmer_widget.dart';

class MomentsLiveTabview extends HookConsumerWidget {
  const MomentsLiveTabview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(momentsNotifierProvider);
    final List<Challenge> upcomingChallenges = state.challenges.where((element) => element.type == ChallengeType.live).toList();

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
      return const ChallengeShimmerWidget();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Gap(8),
                Text(
                  'Live Challenges',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: FontFamily.robotoBold),
                ),
                Text(
                  'Compete in real-time challenges and showcase your skills live!',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: ColorPallete.hintTextColor),
                ),
                const Gap(16),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ChallengesCard(
                    challenge: upcomingChallenges[index],
                    index: index,
                  ),
                );
              },
              childCount: upcomingChallenges.length,
            ),
          ),
        ],
      ),
    );
  }
}
