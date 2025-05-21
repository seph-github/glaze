import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/router.dart';
import '../../../gen/assets.gen.dart';
import '../models/profile/profile.dart';

class GlazersListWidget extends StatelessWidget {
  const GlazersListWidget({super.key, required this.glazes});

  final List<Glaze> glazes;
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return ListView.builder(
      itemCount: glazes.length,
      itemBuilder: (context, index) {
        final profileImageUrl = glazes[index].glazer.profileImageUrl;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () => router.push(
              ViewUserProfileRoute($extra: null, id: glazes[index].glazer.id).location,
            ),
            leading: CircleAvatar(
              radius: 24,
              foregroundImage: profileImageUrl != null ? CachedNetworkImageProvider(profileImageUrl) : null,
              backgroundColor: ColorPallete.blackPearl,
              child: SizedBox(
                width: 48,
                height: 48,
                child: SvgPicture.asset(
                  Assets.images.svg.profileIcon.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '@${glazes[index].glazer.username}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextSpan(
                    text: ' has glazed you content showing strong engagements.',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: ColorPallete.hintTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
