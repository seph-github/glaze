import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            image: imageUrl == null
                ? null
                : DecorationImage(
                    image: NetworkImage(
                      imageUrl!,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
          ),
          child: imageUrl == null
              ? SvgPicture.asset('assets/images/svg/profile.svg')
              : null,
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
