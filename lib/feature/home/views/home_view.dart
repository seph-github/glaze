import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/home/views/new_video_player_view.dart';

import '../../../data/models/video/video_model.dart';
import '../../../repository/user_repository/user_repository.dart';
import '../../../repository/video_repository/video_repository.dart';
import '../widgets/button_icons.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userNotifierProvider);
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(cacheVideoNotifierProvider);

        return state.when(
          data: (data) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(videoRepositoryProvider).fetchVideos(),
                color: Colors.amber,
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                child: PageView.builder(
                  itemCount: data.controllers?.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        NewVideoPlayerView(
                          controller: data.controllers?[index],
                        ),
                        BottomIcons(
                          video: data.model?[index] ??
                              VideoModel(
                                id: '',
                                videoUrl: '',
                                userId: '',
                                thumbnailUrl: '',
                                createdAt: DateTime.now(),
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
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
        child: CircularProgressIndicator(
          color: Colors.amber,
        ),
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
