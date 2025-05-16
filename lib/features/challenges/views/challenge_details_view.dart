import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/features/challenges/models/challenge/challenge.dart';
import 'package:glaze/features/challenges/providers/challenge_provider.dart';
import 'package:glaze/features/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:glaze/utils/app_timer.dart';
import 'package:glaze/utils/string_formatter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/navigation/router.dart';
import '../../../gen/fonts.gen.dart';
import '../widgets/leaderboard_tile.dart';

class ChallengeDetailsView extends HookConsumerWidget {
  const ChallengeDetailsView({
    super.key,
    required this.challenge,
    required this.useColor,
  });

  final Challenge challenge;
  final Color useColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() async {
        await ref.read(challengeNotifierProvider.notifier).getChallengeEntries(challenge.id);
      });
      return null;
    }, []);

    return LoadingLayout(
      appBar: AppBarWithBackButton(
        actions: [
          AppTimer(
            endDate: DateTime.now(),
          ),
          const Gap(12.0),
        ],
      ),
      bottomSheet: _buildJoinChallenge(context),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12.0,
                  0.0,
                  12.0,
                  MediaQuery.viewPaddingOf(context).bottom + 40,
                ),
                child: ListView(
                  children: <Widget>[
                    Column(
                      children: [
                        const Gap(12.0),
                        Container(
                          height: 350,
                          width: MediaQuery.sizeOf(context).width * 0.65,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1 / 2,
                              color: Theme.of(context).colorScheme.inverseSurface,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            image: DecorationImage(
                                image: AssetImage(
                                  Assets.images.png.glazeOnSplash.path,
                                ),
                                fit: BoxFit.cover),
                          ),
                        ),
                        const Gap(12.0),
                      ],
                    ),
                    _buildHeaderSection(context),
                    if (challenge.rules != null) _buildChallengeRuleSection(context),
                    const Gap(12.0),
                    _buildLeaderboardSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildChallengeRuleSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              top: 12.0,
            ),
            child: Text(
              'Challenges rules',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Column(
            children: List.generate(
              challenge.rules?.length ?? 0,
              growable: false,
              (index) {
                final String rank = (index + 1).toString();
                return Column(
                  children: [
                    _buildChallengeRuleTile(
                      context,
                      orderList: rank,
                      rule: challenge.rules?[index] ?? '',
                    ),
                    if (index < (challenge.rules!.length - 1))
                      const Divider(
                        height: 0,
                        indent: 12,
                        endIndent: 12,
                        thickness: 0.5,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeRuleTile(
    BuildContext context, {
    String? orderList,
    required String rule,
  }) {
    return ListTile(
      leading: Container(
        alignment: Alignment.center,
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.inverseSurface, width: 1),
        ),
        child: Text(
          orderList ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: FontFamily.hitAndRun,
              ),
        ),
      ),
      title: Text(
        rule,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.normal,
            ),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(challengeNotifierProvider);
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (state.entries.isNotEmpty)
                  GestureDetector(
                    onTap: () => ChallengeLeaderboardRoute(state.entries).push<void>(context),
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
              ],
            ),
            if (state.isLoading) ...[
              Column(
                children: List.generate(
                  3,
                  (index) {
                    return Shimmer.fromColors(
                      period: Duration(seconds: index + 3),
                      baseColor: ColorPallete.lightBackgroundColor,
                      highlightColor: ColorPallete.inputFilledColor,
                      child: Container(
                        height: 48.0,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: ColorPallete.lightBackgroundColor,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (state.entries.isEmpty)
              const SizedBox(
                height: 80.0,
                child: Center(
                  child: Text('Be the first to participate'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                height: 144,
                child: ListView.separated(
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: state.entries.length < 5 ? state.entries.length : 5,
                  itemBuilder: (context, index) {
                    final rank = index + 1;
                    return LeaderboardTile(
                      useColor: useColor,
                      username: '@${state.entries[index].profile.username}',
                      rank: rank.toString(),
                    );
                  },
                ),
              ),
            const Gap(12.0),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Gap(12.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SvgPicture.asset(
              Assets.images.svg.trophyIcon.path,
              height: 24,
              colorFilter: ColorFilter.mode(
                useColor,
                BlendMode.srcIn,
              ),
            ),
            const Gap(8.0),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: useColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                getPrizeText(challenge.prize ?? ''),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
              ),
            ),
          ],
        ),
        const Gap(12.0),
        Text(
          challenge.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: useColor,
              ),
        ),
        Text(
          challenge.description ?? '',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFamily: FontFamily.robotoRegular,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
        ),
        const Gap(8.0),
        if (challenge.tags != null)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            runAlignment: WrapAlignment.end,
            children: challenge.tags!.map((tag) {
              return Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: useColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  '#$tag',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }).toList(),
          ),
        const Gap(16.0),
      ],
    );
  }

  Widget _buildJoinChallenge(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: PrimaryButton(
          label: 'Join',
          onPressed: () async => ChallengeSubmitEntryRoute(challengeId: challenge.id).push<void>(context),
        ),
      ),
    );
  }
}
