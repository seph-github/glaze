import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class RecruiterHeaderCard extends StatelessWidget {
  const RecruiterHeaderCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: ColorPallete.primaryColor,
        ),
        color: ColorPallete.magenta.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Benefits of Being a Recruiter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ColorPallete.primaryColor.withValues(red: 2),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(5),
          Row(
            children: <Widget>[
              SvgPicture.asset(
                Assets.images.svg.starIcon.path,
                height: 18.0,
              ),
              const Gap(15),
              Text(
                'You will get Verified Badge.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ColorPallete.primaryColor.withValues(red: 2),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Gap(5),
          Row(
            children: <Widget>[
              SvgPicture.asset(
                Assets.images.svg.starIcon.path,
                height: 18.0,
              ),
              const Gap(15),
              Text(
                'You can DM users.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ColorPallete.primaryColor.withValues(red: 2),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Gap(5),
          Row(
            children: <Widget>[
              SvgPicture.asset(
                Assets.images.svg.starIcon.path,
                height: 18.0,
              ),
              const Gap(15),
              Text(
                'You can use Exclusive Access.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ColorPallete.primaryColor.withValues(red: 1),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
