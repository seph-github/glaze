import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/assets.gen.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.useColor,
    required this.username,
    required this.rank,
  });

  final Color useColor;
  final String username;
  final String rank;

  Color colorByRank(int rank) {
    switch (rank) {
      case 1:
        return ColorPallete.gold;
      case 2:
        return ColorPallete.silver;
      case 3:
        return ColorPallete.bronze;
      default:
        return ColorPallete.borderColor.withValues(alpha: 0.6);
    }
  }

  Widget leadingWidget(BuildContext context, int rank) {
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return SvgPicture.asset(
          Assets.images.svg.trophyIcon.path,
          height: 24.0,
          colorFilter: ColorFilter.mode(
            colorByRank(rank),
            BlendMode.srcIn,
          ),
        );
      default:
        return Text(
          rank.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: colorByRank(int.parse(rank)),
            width: 2,
          )),
      tileColor: colorByRank(int.parse(rank)).withValues(alpha: 0.7),
      title: Text(
        username,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        'You need 30 more glaze to rank up.',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
      ),
      leading: Container(
        alignment: Alignment.center,
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: colorByRank(int.parse(rank)),
            width: 1,
          ),
        ),
        child: leadingWidget(
          context,
          int.parse(rank),
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
