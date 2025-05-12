import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/gen/assets.gen.dart';

import '../../../core/styles/color_pallete.dart';
import '../../../gen/fonts.gen.dart';

class AppTimer extends StatefulWidget {
  final DateTime? startDate;
  final DateTime endDate;

  const AppTimer({
    super.key,
    this.startDate,
    required this.endDate,
  });

  @override
  State<AppTimer> createState() => _ChallengeTimerState();
}

class _ChallengeTimerState extends State<AppTimer> {
  late Duration remainingTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.endDate.difference(DateTime.now());
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(widget.endDate)) {
        timer.cancel();
        setState(() {
          remainingTime = Duration.zero;
        });
      } else {
        setState(() {
          remainingTime = widget.endDate.difference(now);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (remainingTime == Duration.zero) {
      return Text(
        'Expired',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFamily: FontFamily.robotoRegular,
              color: ColorPallete.parlourRed,
              fontSize: 16.0,
            ),
      );
    }

    final days = remainingTime.inDays;
    final hours = remainingTime.inHours % 24;
    final minutes = remainingTime.inMinutes % 60;
    final seconds = remainingTime.inSeconds % 60;

    return Row(
      children: [
        SvgPicture.asset(
          Assets.images.svg.timerIcon.path,
          height: 24.0,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.inverseSurface,
            BlendMode.srcIn,
          ),
        ),
        const Gap(4),
        Text(
          '${days == 0 ? '' : '$days:'}${hours == 0 ? '' : '$hours:'}${minutes == 0 ? '' : '$minutes:'}${seconds}s',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontFamily: FontFamily.robotoRegular,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
        ),
      ],
    );
  }
}
