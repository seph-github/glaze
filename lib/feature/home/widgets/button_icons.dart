import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:glaze/repository/auth_service/auth_service_provider.dart';
import 'package:glaze/repository/glaze_repository/glaze_repository.dart';
import 'package:go_router/go_router.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../core/routing/router.dart';
import '../views/upload_moment_view.dart';

class BottomIcons extends ConsumerWidget {
  const BottomIcons({super.key, required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showMustLoginWarning(GoRouter router) async {
      await Dialogs.createContentDialog(
        context,
        title: 'Error',
        content: 'You must logged in to upload a moment',
        onPressed: () {
          router.pushReplacement(const AuthRoute().location);
        },
      );
    }

    final glazeNotifier = ref.watch(glazeNotifierProvider);
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
                  final router = GoRouter.of(context);
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(router);
                  }

                  if (context.mounted) {
                    return await Dialogs.showBottomDialog(
                      context,
                      child: UploadMoment(),
                    );
                  }
                },
              ),
              const Icon(Icons.file_open),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: glazeNotifier.when(
                  data: (data) {
                    final isGlazed =
                        data.any((element) => element.videoId == video.id);
                    return isGlazed
                        ? const Icon(Icons.thumb_up)
                        : const Icon(Icons.thumb_up_alt_outlined);
                  },
                  loading: () => const Icon(Icons.thumb_up_alt_outlined),
                  error: (error, stackTrace) =>
                      const Icon(Icons.thumb_up_alt_outlined),
                ),
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(router);
                  }
                  await ref
                      .read(glazeRepositoryProvider)
                      .onGlaze(userId: user!.id, videoId: video.id)
                      .whenComplete(
                        () => ref.refresh(glazeNotifierProvider),
                      );
                },
              ),
              const Icon(Icons.share),
              IconButton(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(router);
                  }

                  router.push(const ProfileRoute().location);
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
