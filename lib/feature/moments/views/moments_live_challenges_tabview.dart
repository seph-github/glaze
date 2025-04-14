import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:gap/gap.dart';
import 'package:glaze/components/snack_bar/custom_snack_bar.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/moments/providers/moments_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../gen/fonts.gen.dart';
import '../widgets/challenges_card.dart';

class MomentsLiveChallengesTabview extends HookConsumerWidget {
  const MomentsLiveChallengesTabview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(momentsNotifierProvider);

    useEffect(() {
      Future.microtask(
        () async =>
            await ref.read(momentsNotifierProvider.notifier).getChallenges(),
      );

      return null;
    }, []);

    ref.listen(
      momentsNotifierProvider,
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          final errorMessage = next.error.toString();

          CustomSnackBar.showSnackBar(context, message: errorMessage);
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
              challenge: state.challenges[index],
            ),
            childCount: state.challenges.length,
          ),
        ),
      ],
    );
  }
}
