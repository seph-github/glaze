import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/repository/auth_service/auth_service_provider.dart';

import '../providers/home_controller_provider.dart';

class BottomIcons extends ConsumerWidget {
  const BottomIcons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height / 5,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.add_a_photo_rounded),
                onPressed: () async {
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();
                  if (context.mounted) {
                    ref
                        .read(homeControllerProvider)
                        .onUploadMoment(context, user: user);
                  }
                },
              ),
              const Icon(Icons.file_open),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.thumb_up),
              const Icon(Icons.share),
              IconButton(
                onPressed: () async {
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (context.mounted) {
                    ref
                        .read(homeControllerProvider)
                        .onProfile(context, user: user);
                  }
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
