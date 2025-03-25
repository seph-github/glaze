import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({
    super.key,
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorPallete.strawberryGlaze,
              width: 5,
            ),
            image: DecorationImage(
              image: NetworkImage(
                imageUrl ??
                    'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/no-profile-picture-icon.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPallete.parlourRed,
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.edit,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
