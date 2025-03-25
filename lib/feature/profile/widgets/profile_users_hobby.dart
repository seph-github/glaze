import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileHobbies extends StatelessWidget {
  const ProfileHobbies({
    super.key,
    this.hobby,
    this.icon = Icons.sports_baseball_outlined,
  });

  final String? hobby;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18.0,
        ),
        const Gap(5),
        Text(
          hobby ?? 'Hobby',
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
