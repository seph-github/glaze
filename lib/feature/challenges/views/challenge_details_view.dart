import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/templates/loading_layout.dart';
import 'package:glaze/gen/assets.gen.dart';
import 'package:glaze/utils/app_timer.dart';
import 'package:glaze/utils/string_formatter.dart';

import '../../../gen/fonts.gen.dart';

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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
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
                            color: Colors.white,
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
                        color: ColorPallete.persianFable,
                      ),
                ),
              ),
              const Gap(16.0),
              Column(
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
                      Text(
                        'View All',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                  const Gap(12.0),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorPallete.inputFilledColor,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Column(
                      children: [
                        _buildLeaderBoardTile(context),
                        const Divider(
                          height: 0,
                          indent: 12,
                          endIndent: 12,
                          thickness: 0.5,
                        ),
                        _buildLeaderBoardTile(context),
                        const Divider(
                          height: 0,
                          indent: 12,
                          endIndent: 12,
                          thickness: 0.5,
                        ),
                        _buildLeaderBoardTile(context),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildLeaderBoardTile(BuildContext context) {
    return ListTile(
      title: Text(
        'hoopStar01',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        'You need 30 more glaze to rank up.',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.normal,
              color: ColorPallete.hintTextColor,
            ),
      ),
      leading: Container(
        alignment: Alignment.center,
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorPallete.inputFilledColor,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          '#1',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      trailing: Container(
        width: 70.0,
        height: 36.0,
        decoration: BoxDecoration(
          border: Border.all(color: useColor, width: 0.25),
          color: useColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              Assets.images.svg.glazeDonutsIcon.path,
              height: 15.0,
              colorFilter: ColorFilter.mode(
                useColor,
                BlendMode.srcIn,
              ),
            ),
            const Gap(6.0),
            Text(
              '120',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: useColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
