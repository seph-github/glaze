import 'package:flutter/material.dart';

import 'description_text.dart';
import 'user_header.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key, required this.profileImageUrl, required this.username, required this.description});

  final String profileImageUrl;
  final String username;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          UserHeader(profileImageUrl: profileImageUrl, username: username),
          DescriptionText(text: description),
        ],
      ),
    );
  }
}
