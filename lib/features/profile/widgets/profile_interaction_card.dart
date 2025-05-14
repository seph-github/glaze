import 'package:flutter/material.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import 'package:go_router/go_router.dart';

import '../models/profile/profile.dart';

class ProfileInteractionCard extends StatelessWidget {
  const ProfileInteractionCard({
    super.key,
    required this.followers,
    required this.following,
    required this.glazes,
  });

  final List<Interact> followers;
  final List<Interact> following;
  final List<Glaze> glazes;

  void navigateToPage(int initialIndex, GoRouter router) {
    router.push(
        ProfileInteractiveRoute(
          initialIndex: initialIndex,
        ).location,
        extra: {
          'following': following,
          'followers': followers,
          'glazes': glazes
        });
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    return Container(
      height: 80.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: ColorPallete.primaryColor,
          width: 0.25,
        ),
      ),
      child: Row(
        children: [
          _buildInteractiveButton(
            value: following.length,
            label: 'Following',
            onPressed: () => navigateToPage(0, router),
          ),
          _buildVerticalDivider(),
          _buildInteractiveButton(
            value: followers.length,
            label: 'Followers',
            onPressed: () => navigateToPage(1, router),
          ),
          _buildVerticalDivider(),
          _buildInteractiveButton(
            value: glazes.length,
            label: 'Total Glazes',
            onPressed: () => navigateToPage(2, router),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const VerticalDivider(
      width: 0.5,
      thickness: 0.5,
      color: ColorPallete.primaryColor,
      endIndent: 20,
      indent: 20,
    );
  }

  Widget _buildInteractiveButton({
    VoidCallback? onPressed,
    int? value,
    required String label,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(),
          foregroundColor: Colors.grey,
          fixedSize: const Size.fromWidth(double.infinity),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: ColorPallete.primaryColor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
                color: ColorPallete.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
