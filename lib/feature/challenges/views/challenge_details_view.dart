import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/components/buttons/primary_button.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:glaze/utils/app_timer.dart';
import 'package:glaze/utils/string_formatter.dart';

import '../../../components/modals/glaze_modals.dart';
import '../../../core/navigation/router.dart';
import '../../../gen/fonts.gen.dart';
import '../widgets/leaderboard_tile.dart';

class ChallengeDetailsView extends StatelessWidget {
  const ChallengeDetailsView({
    super.key,
    required this.challenge,
    required this.useColor,
  });

  final Challenge challenge;
  final Color useColor;

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        actions: [
          AppTimer(
            endDate: DateTime.now(),
          ),
          const Gap(12.0),
        ],
      ),
      floatingActionButton: _buildAcceptChallenge(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                    _buildChallengeRuleSection(context),
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
          _buildChallengeRuleTile(
            context,
            orderList: '1',
            rule: 'Make a video similar to the content creator above',
          ),
          const Divider(
            height: 0,
            indent: 12,
            endIndent: 12,
            thickness: 0.5,
          ),
          _buildChallengeRuleTile(context, orderList: '2', rule: 'Use the same audio'),
          const Divider(
            height: 0,
            indent: 12,
            endIndent: 12,
            thickness: 0.5,
          ),
          _buildChallengeRuleTile(context, orderList: '3', rule: 'Use the hashtags #happy'),
        ],
      ),
    );
  }

  ListTile _buildChallengeRuleTile(
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
            GestureDetector(
              onTap: () async => await const ChallengeLeaderboardRoute().push<void>(context),
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
        const Gap(12.0),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            children: [
              LeaderboardTile(
                useColor: useColor,
                username: 'first',
                rank: 1.toString(),
              ),
              const Divider(
                height: 0,
                indent: 12,
                endIndent: 12,
                thickness: 0.5,
              ),
              LeaderboardTile(
                useColor: useColor,
                username: 'second',
                rank: 2.toString(),
              ),
              const Divider(
                height: 0,
                indent: 12,
                endIndent: 12,
                thickness: 0.5,
              ),
              LeaderboardTile(
                useColor: useColor,
                username: 'thirdy',
                rank: 3.toString(),
              ),
            ],
          ),
        ),
        const Gap(12.0),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
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
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.5,
              child: Text(
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
            ),
            const Spacer(),
            Container(
              alignment: Alignment.center,
              height: 24,
              width: 96.0,
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
        const Gap(4.0),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            challenge.description ?? '',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontFamily: FontFamily.robotoRegular,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
          ),
        ),
        const Gap(16.0),
      ],
    );
  }

  Widget _buildAcceptChallenge(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(12.0),
      child: SafeArea(
        child: PrimaryButton(
          label: 'Accept Challenge',
          onPressed: () async {
            await GlazeModal.showUploadContentModalPopUp(context);
          },
        ),
      ),
    );
  }
}
