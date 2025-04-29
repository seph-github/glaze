import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/challenges/models/challenge.dart';
import 'package:glaze/feature/challenges/widgets/circle_stack.dart';
import 'package:glaze/gen/fonts.gen.dart';

import '../../../gen/assets.gen.dart';
import '../../../utils/app_timer.dart';

class ChallengesCard extends StatelessWidget {
  const ChallengesCard({
    super.key,
    required this.challenge,
    required this.index,
  });

  final Challenge challenge;
  final int index;

  static const List<Color> lightColors = [
    Color(0xFFFFEB3B), // Bright Yellow
    Color(0xFF4CAF50), // Vibrant Greenx
    Color(0xFF2196F3), // Bright Blue
    Color(0xFFFF5722), // Bright Orange
    Color(0xFF9C27B0), // Bright Purple
  ];

  String _getPrizeText(String value) {
    if (value.isEmpty) return '';

    if (value.contains('\$')) {
      return '\$${value.replaceAll('\$', '')}';
    }
    return '\$$value';
  }

  @override
  Widget build(BuildContext context) {
    final randomColor = lightColors[index % lightColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: randomColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: randomColor, width: 0.05),
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
                      color: ColorPallete.persianFable,
                      fontSize: 12.0,
                    ),
              ),
            ),
          _buildDurationSection(),
          const Gap(8),
          Container(
            alignment: Alignment.center,
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: randomColor.withValues(alpha: 0.4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _getPrizeText(challenge.prize ?? ''),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: FontFamily.robotoSemiBold,
                        color: Colors.white,
                      ),
                ),
                Text(
                  _getPrizeText(challenge.prize ?? ''),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: FontFamily.robotoBold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                ),
              ],
            ),
          ),
          // const Gap(12),
          // PrimaryButton(
          //   onPressed: () {},
          //   label: 'Join the Challenge',
          //   borderRadius: 16.0,
          //   backgroundColor: Colors.yellow,
          // ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          Assets.images.svg.timerIcon.path,
          height: 24.0,
          colorFilter: const ColorFilter.mode(
            ColorPallete.persianFable,
            BlendMode.srcIn,
          ),
        ),
        const Gap(8),
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
            overflow:
                TextOverflow.ellipsis, // Ensures the text is fully visible
            softWrap: true, // Allows the text to wrap to a new line
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
