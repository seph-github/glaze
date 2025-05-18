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
        return ColorPallete.lightBackgroundColor;
    }
  }

  Widget leadingWidget(BuildContext context, int rank) {
    if (rank == 1) {
      return SvgPicture.asset(
        Assets.images.svg.trophyIcon.path,
        height: 28.0,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      );
    }

    return Text(
      _rankWithSuperscript(rank),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Color getBorderColor(int rank) {
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return colorByRank(rank);

      default:
        return Colors.white;
    }
  }

  String _rankWithSuperscript(int rank) {
    final suffix = switch (rank) {
      1 => 'ˢᵗ',
      2 => 'ⁿᵈ',
      3 => 'ʳᵈ',
      _ => 'ᵗʰ',
    };
    return '$rank$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          colors: [
            colorByRank(int.parse(rank)).withValues(alpha: 1),
            colorByRank(int.parse(rank)).withValues(alpha: 0.9),
            colorByRank(int.parse(rank)).withValues(alpha: 0.85),
            colorByRank(int.parse(rank)).withValues(alpha: 0.8),
            colorByRank(int.parse(rank)).withValues(alpha: 0.75),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [
            0.45,
            0.55,
            0.6,
            0.7,
            0.8,
          ]..reversed,
        ),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: colorByRank(int.parse(rank)),
            width: 2,
          ),
        ),
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
            gradient: LinearGradient(
              colors: [
                colorByRank(int.parse(rank)).withValues(alpha: 0.5),
                colorByRank(int.parse(rank)).withValues(alpha: 0.47),
                colorByRank(int.parse(rank)).withValues(alpha: 0.44),
                colorByRank(int.parse(rank)).withValues(alpha: 0.41),
                colorByRank(int.parse(rank)).withValues(alpha: 0.38),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.45,
                0.55,
                0.6,
                0.7,
                0.8,
              ]..reversed,
            ),
            border: Border.all(
              color: getBorderColor(int.parse(rank)),
              // color: colorByRank(int.parse(rank)),
              // color: int.parse(rank) < 3 ? colorByRank(int.parse(rank)) : Colors.white,
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
      ),
    );
  }
}
