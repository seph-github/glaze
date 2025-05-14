import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileUserInterest extends StatelessWidget {
  const ProfileUserInterest({
    super.key,
    this.interest,
    this.icon = Icons.sports_baseball_outlined,
  });

  final String? interest;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.0,
        ),
        const Gap(3),
        Text(
          interest ?? '',
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
