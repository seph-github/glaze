import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/data/models/video/video_model.dart';
import 'package:glaze/data/repository/auth_repository/auth_repository_provider.dart';
import 'package:glaze/data/repository/glaze_repository/glaze_repository.dart';
import 'package:go_router/go_router.dart';

import '../../../components/dialogs/dialogs.dart';
import '../../../core/routing/router.dart';
import '../views/upload_moment_view.dart';

class BottomIcons extends ConsumerWidget {
  const BottomIcons({super.key, required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showMustLoginWarning(BuildContext context) async {
      final router = GoRouter.of(context);
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
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(context);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white,
                        width: 0.5,
                      ),
                      gradient: const RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.black,
                        ],
                        tileMode: TileMode.decal,
                        focalRadius: 40.0,
                        focal: Alignment.topRight,
                        stops: [
                          0.2,
                          0.4,
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                          offset: Offset(0.0, 0.0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Dark shadow to the bottom
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 20,
                      offset: Offset(8, 8),
                      blurStyle: BlurStyle.inner,
                    ),
                    // Light shadow to simulate light reflection
                    // BoxShadow(
                    //   color: Colors.white24,
                    //   blurRadius: 1,
                    //   offset: Offset(1, 1),
                    // ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150 / 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                          radius: 0.35,
                          focal: Alignment.topCenter,
                          center: Alignment.topRight,
                          focalRadius: 0.3,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: glazeNotifier.when(
                  data: (data) {
                    final isGlazed =
                        data.any((element) => element.videoId == video.videoId);
                    return isGlazed
                        ? const Icon(Icons.thumb_up)
                        : const Icon(Icons.thumb_up_alt_outlined);
                  },
                  loading: () => const Icon(Icons.thumb_up_alt_outlined),
                  error: (error, stackTrace) =>
                      const Icon(Icons.thumb_up_alt_outlined),
                ),
                onPressed: () async {
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(context);
                  }
                  await ref
                      .read(glazeRepositoryProvider)
                      .onGlaze(userId: user!.id, videoId: video.videoId)
                      .whenComplete(
                        () => ref.refresh(glazeNotifierProvider),
                      );
                },
              ),
              const Icon(Icons.share),
              // TODO:
              IconButton(
                onPressed: () async {
                  final user =
                      await ref.watch(authServiceProvider).getCurrentUser();

                  if (user == null && context.mounted) {
                    return await showMustLoginWarning(context);
                  }

                  // if (context.mounted) {
                  //   context.push(ProfileRoute().location);
                  // }
                },
                icon: const Icon(Icons.account_circle),
              ),
              // ClipRRect(
              //   clipBehavior: Clip.none,
              //   child: Container(
              //     width: 50.0,
              //     height: 50.0,
              //     decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.white30.withValues(alpha: 0.3),
              //         border: Border.all(
              //           color: Colors.white30,
              //         ),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black38.withValues(alpha: 0.3),
              //             spreadRadius: 1,
              //             blurRadius: 1,
              //             offset: const Offset(-0.5, -0.5),
              //           ),
              //         ],
              //         gradient: LinearGradient(
              //           colors: [
              //             Colors.white,
              //             Colors.white12,
              //           ],
              //         )),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
