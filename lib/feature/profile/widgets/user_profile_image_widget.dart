import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:glaze/gen/assets.gen.dart';

class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({
    super.key,
    this.imageUrl,
    this.username,
    this.bio,
  });

  final String? imageUrl;
  final String? username;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorPallete.primaryColor,
              width: 2,
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
              ? Transform.scale(
                  scale: 0.75,
                  child: SvgPicture.asset(
                    Assets.images.svg.profileIcon.path,
                    height: 10,
                  ),
                )
              : null,
        ),
        Text(
          username ?? '',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (bio != null)
          SizedBox(
            width: width * 0.6,
            child: Text(
              bio ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        const Gap(8),
      ],
    );
  }
}
