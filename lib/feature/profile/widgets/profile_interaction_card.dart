import 'package:flutter/material.dart';
import 'package:glaze/core/navigation/router.dart';
import 'package:go_router/go_router.dart';

class ProfileInteractionCard extends StatelessWidget {
  const ProfileInteractionCard({
    super.key,
    this.followers,
    this.following,
    this.glazes,
  });

  final int? followers;
  final int? following;
  final int? glazes;

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    return Container(
      height: 80.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey, width: 0.25),
      ),
      child: Row(
        children: [
          _buildInteractiveButton(
            value: following,
            label: 'Following',
            onPressed: () {
              router.push(const ProfileInteractiveRoute(
                initialIndex: 0,
              ).location);
            },
          ),
          _buildVerticalDivider(),
          _buildInteractiveButton(
            value: followers,
            label: 'Followers',
            onPressed: () => router.push(const ProfileInteractiveRoute(
              initialIndex: 1,
            ).location),
          ),
          _buildVerticalDivider(),
          _buildInteractiveButton(
            value: glazes,
            label: 'Total Glazes',
            onPressed: () => router.push(const ProfileInteractiveRoute(
              initialIndex: 2,
            ).location),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const VerticalDivider(
      width: 0.5,
      thickness: 0.5,
      color: Colors.grey,
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
        onPressed: () {
          onPressed?.call();
        },
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
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
