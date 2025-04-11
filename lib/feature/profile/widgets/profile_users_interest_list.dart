import 'package:flutter/material.dart';
import 'package:glaze/feature/profile/widgets/profile_users_interest.dart';

class ProfileUsersInterestList extends StatelessWidget {
  const ProfileUsersInterestList({
    super.key,
    this.interests,
  });

  final List<String>? interests;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (interests == null || interests!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: width * 0.75,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: interests!
            .map(
              (interest) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileUserInterest(interest: interest),
                  if (interest != interests!.last)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
