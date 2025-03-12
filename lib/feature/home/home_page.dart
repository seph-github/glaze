import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/home/view/video_player_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:glaze/helper/auth_check_helper.dart';
import 'package:glaze/providers/file_picker/file_picker_provider.dart';
import 'package:glaze/providers/video_provider/video_provider.dart';
import 'package:glaze/routing/auth_guard/auth_guard.dart';
import 'package:glaze/routing/router.dart';
import 'package:go_router/go_router.dart';

import '../../components/dialogs/dialogs.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(videoNotifierProvider);
        return state.when(
          data: (data) {
            return _VideoListView(data: data);
          },
          error: (error, stackTrace) => _ErrorView(
            error: error.toString(),
          ),
          loading: () => const _LoadingView(),
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error),
      ),
    );
  }
}

class _VideoListView extends StatelessWidget {
  final List<dynamic> data;

  const _VideoListView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider.builder(
            itemCount: data.length,
            itemBuilder: (context, index, realIndex) {
              return VideoPlayerView(
                url: data[index].videoUrl,
              );
            },
            options: CarouselOptions(
              scrollDirection: Axis.vertical,
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              pageSnapping: true,
              aspectRatio: 9 / 16,
              enableInfiniteScroll: false,
            ),
          ),
          const _BottomIcons(),
        ],
      ),
    );
  }
}

class _BottomIcons extends StatelessWidget {
  const _BottomIcons();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height / 4,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    icon: const Icon(Icons.add_a_photo_rounded),
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      final hasUser =
                          await AuthCheckHelper.isLoggedIn(ref: ref);

                      if (hasUser) {
                        return await ref
                            .read(filePickerNotifierProvider.notifier)
                            .pickFile();
                      } else {
                        router.push(const LoginRoute().location);
                      }
                    },
                    // onPressed: () async =>
                    //     await Dialogs.showBottomDialog(context),
                  );
                },
              ),
              const Icon(Icons.account_circle),
            ],
          ),
          const Column(
            children: [
              Icon(Icons.account_circle),
              Icon(Icons.account_circle),
              Icon(Icons.account_circle),
            ],
          ),
        ],
      ),
    );
  }
}
