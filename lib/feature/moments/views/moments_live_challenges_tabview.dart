import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/moments/providers/moments_provider.dart';

import '../../../gen/fonts.gen.dart';
import '../widgets/challenges_card.dart';

class MomentsLiveChallengesTabview extends HookWidget {
  const MomentsLiveChallengesTabview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen(momentsNotifierProvider, (prev, next) {
          if (next.error != null && next.error != prev?.error) {
            final errorMessage = next.error.toString();

            CustomSnackBar.showSnackBar(context, message: errorMessage);
          }
        });

        final state = ref.watch(momentsNotifierProvider);

        // print('Upcoming challenges: $state');

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Upcoming Challenges',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontFamily: FontFamily.robotoBold),
                  ),
                  Text(
                    'Stay tuned for exciting challenges to test your skills!',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: ColorPallete.hintTextColor),
                  ),
                  const Gap(10),
                  // const ChallengesCard(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ChallengesCard(
                  challenge: state.upcomingChallenges[index],
                ),
                childCount: state.upcomingChallenges.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
