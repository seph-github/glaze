import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';

class ProfileAchievementsCard extends StatelessWidget {
  const ProfileAchievementsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(fontSize: 20),
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AchievementsButton(
                label: '🍩',
              ),
              AchievementsButton(
                label: '✨',
              ),
              AchievementsButton(
                label: '🌀',
              ),
              AchievementsButton(
                label: '💎',
              ),
            ],
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
