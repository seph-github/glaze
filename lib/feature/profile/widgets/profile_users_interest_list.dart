import 'package:flutter/material.dart';
import 'package:glaze/feature/profile/widgets/profile_users_hobby.dart';

class ProfileUsersInterestList extends StatelessWidget {
  const ProfileUsersInterestList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final List<String> interests = ['Art', 'Music', 'Sports'];

    return SizedBox(
      height: 20,
      width: width * 0.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: interests
            .map(
              (interest) => Row(
                children: [
                  ProfileHobbies(hobby: interest),
                  if (interest != interests.last)
                    Container(
                      width: 6,
                      height: 6,
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
