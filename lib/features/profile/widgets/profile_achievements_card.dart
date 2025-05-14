import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class ProfileAchievementsCard extends StatelessWidget {
  const ProfileAchievementsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = [
      Assets.images.svg.privacyProtectorBadge.path,
      Assets.images.svg.heartfeltCommunicatorBadge.path,
      Assets.images.svg.gemCollectorBadge.path,
      Assets.images.svg.timeKeeperBadge.path,
      Assets.images.svg.sparkIgniterBadge.path,
      Assets.images.svg.achievementAceBadge.path,
      Assets.images.svg.precisionArcherBadge.path,
      Assets.images.svg.swordmasterBadge.path,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(fontSize: 20),
              ),
              if (achievements.length >= 8)
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
            ],
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (_, index) {
              return Transform.scale(
                scale: 0.8,
                child: SvgPicture.asset(
                  achievements[index],
                  height: 70,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AchievementsButton extends StatelessWidget {
  const AchievementsButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 80.0,
      padding: const EdgeInsets.only(left: 8.0),
      decoration: BoxDecoration(
        color: Colors.white12,
        border: const Border.fromBorderSide(
          BorderSide(
            color: ColorPallete.strawberryGlaze,
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 32,
        ),
      ),
    );
  }
}
