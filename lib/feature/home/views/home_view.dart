import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glaze/feature/home/views/video_player_view.dart';

import '../../../repository/video_repository/video_repository.dart';
import '../widgets/button_icons.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

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

class _VideoListView extends ConsumerWidget {
  final List<dynamic> data;

  const _VideoListView({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      primary: true,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(videoRepositoryProvider).fetchVideos(),
        color: Colors.amber,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        child: PageView.builder(
          itemCount: data.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayerView(
                  url: data[index].videoUrl,
                  thumbnailUrl: data[index].thumbnailUrl,
                ),
                BottomIcons(
                  video: data[index],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
