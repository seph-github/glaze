import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/config/enum/challenge_type.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/challenges/widgets/circle_stack.dart';
import 'package:glaze/gen/fonts.gen.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils/app_timer.dart';
import '../../../utils/string_formatter.dart';

class ChallengesCard extends StatelessWidget {
  const ChallengesCard({
    super.key,
    required this.challenge,
    required this.index,
  });

  final Challenge challenge;
  final int index;

  static const List<Color> lightColors = [
    Color(0xFFF875AA),
    Color(0xFF6AD4DD),
    Color(0xFFA0D683),
    Color(0xFFFEEE91),
    Color(0xFF2196F3),
  ];

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final randomColor = lightColors[index % lightColors.length];

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: randomColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: randomColor, width: 0.05),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: randomColor.withValues(alpha: 0.3),
                blurRadius: 100,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              _buildTitleSharingSection(randomColor, context),
              if (challenge.description != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    challenge.description ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: FontFamily.robotoRegular,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontSize: 12.0,
                        ),
                  ),
                ),
              _buildDurationSection(),
              const Gap(8),
              Container(
                alignment: Alignment.center,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: randomColor.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        getPrizeText(challenge.prize ?? ''),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: FontFamily.robotoBold,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              PrimaryButton(
                onPressed: () async {
                  router.push(
                    const ChallengeDetailsRoute().location,
                    extra: {
                      'challenge': challenge,
                      'color': randomColor.toARGB32(),
                    },
                  );
                },
                label: challenge.type == ChallengeType.live ? 'Leaderboard' : 'Join the Challenge',
                icon: null,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      // color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                borderRadius: 16.0,
                height: 40,
                backgroundColor: randomColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSection() {
    return Row(
      children: <Widget>[
        AppTimer(startDate: challenge.startDate, endDate: challenge.endDate),
        const Spacer(),
        const SizedBox(
          width: 100,
          height: 30,
          child: CircleStackPage(),
        ),
      ],
    );
  }

  Widget _buildTitleSharingSection(Color randomColor, BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          Assets.images.svg.trophyIcon.path,
          height: 24.0,
          colorFilter: ColorFilter.mode(
            randomColor,
            BlendMode.srcIn,
          ),
        ),
        const Gap(8),
        SizedBox(
          width: width * 0.65,
          child: Text(
            challenge.title,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: FontFamily.robotoBold,
                  color: randomColor,
                ),
          ),
        ),
        const Spacer(),
        MorphismWidget.circle(
          size: 32.0,
          child: SvgPicture.asset(
            Assets.images.svg.shareIcon.path,
          ),
        ),
      ],
    );
  }
}
