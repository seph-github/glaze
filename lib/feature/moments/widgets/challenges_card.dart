import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/components/morphism_widget.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/feature/moments/models/challenge.dart';
import 'package:glaze/gen/fonts.gen.dart';

import '../../../gen/assets.gen.dart';

class ChallengesCard extends StatelessWidget {
  const ChallengesCard({
    super.key,
    required this.challenge,
  });

  final Challenge challenge;

  static const List<Color> lightColors = [
    Color(0xFFFFEB3B), // Bright Yellow
    Color(0xFF4CAF50), // Vibrant Green
    Color(0xFF2196F3), // Bright Blue
    Color(0xFFFF5722), // Bright Orange
    Color(0xFF9C27B0), // Bright Purple
  ];

  @override
  Widget build(BuildContext context) {
    final randomColor = (List<Color>.from(lightColors)..shuffle()).first;

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
          Row(
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
              Text(
                challenge.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: FontFamily.robotoBold,
                      color: randomColor,
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
          ),
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
          const Gap(12),
          Row(
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
              Text(
                _formatDuration(challenge.duration!),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: FontFamily.robotoRegular,
                      color: ColorPallete.persianFable,
                      fontSize: 16.0,
                    ),
              ),
              const Spacer(),
              const SizedBox(
                width: 100, // To constrain the width of the CircleStackPage
                height: 30, // Match circle height
                child: CircleStackPage(),
              ),
            ],
          ),
          const Gap(12),
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
                  challenge.prize ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: FontFamily.robotoSemiBold,
                        color: Colors.white,
                      ),
                ),
                Text(
                  challenge.price == null
                      ? ''
                      : '\$${challenge.price?.toStringAsFixed(0)}',
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

  String _formatDuration(Duration duration) {
    final days = duration.inDays.toString().padLeft(2, '0');
    final hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$days:$hours:$minutes:$seconds';
  }
}

class CircleStackPage extends StatelessWidget {
  const CircleStackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Restrict height to avoid overflow
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22.5, // 3/4 overlap of 30 is 22.5
            child: const CircleWidget(),
          );
        }),
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  const CircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
