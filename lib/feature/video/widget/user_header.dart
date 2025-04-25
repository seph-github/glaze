import 'package:flutter/material.dart';
import 'package:glaze/feature/video/widget/glaze_button.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key, required this.profileImageUrl, required this.username});

  final String profileImageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        CircleAvatar(radius: 20, backgroundImage: NetworkImage(profileImageUrl)),
        Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const GlazeButton(),
      ],
    );
  }
}
