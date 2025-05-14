import 'package:flutter/material.dart';
import 'package:glaze/features/profile/models/profile/profile.dart';
import 'package:glaze/features/profile/widgets/profile_users_interest_list.dart';
import 'package:glaze/features/profile/widgets/user_profile_image_widget.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    this.profile,
    this.backgroundColor,
  });

  final Profile? profile;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75 + kToolbarHeight,
          color: backgroundColor,
        ),
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 55,
              color: backgroundColor,
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  UserProfileImageWidget(
                    imageUrl: profile?.profileImageUrl,
                    username: profile?.username,
                    bio: profile?.bio,
                  ),
                  ProfileUsersInterestList(
                    interests: profile?.interests ?? [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
